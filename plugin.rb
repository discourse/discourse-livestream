# frozen_string_literal: true

# name: discourse-livestream
# about: Plugin to add livestream functionality to Discourse
# version: 0.0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-livestream
# required_version: 2.7.0

enabled_site_setting :discourse_livestream_enabled

register_asset "stylesheets/common/base-common.scss"
register_asset "stylesheets/desktop/base-desktop.scss", :desktop
register_asset "stylesheets/mobile/base-mobile.scss", :mobile

Discourse::Application.routes.append { mount ::DiscourseLivestream::Engine, at: "/" }

require_relative "lib/discourse_livestream/topic_extension"
require_relative "lib/discourse_livestream/chat_channel_extension"
require_relative "lib/discourse_livestream/handle_topic_chat_channel_creation"
require_relative "app/models/discourse_livestream/topic_chat_channel"

after_initialize do
  require_relative "jobs/regular/recalculate_user_livestream_channel_memberships"

  module ::DiscourseLivestream
    PLUGIN_NAME = "discourse-livestream"

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseLivestream
    end
  end

  reloadable_patch do
    Topic.prepend DiscourseLivestream::TopicExtension
    Chat::Channel.prepend DiscourseLivestream::ChatChannelExtension

    add_to_serializer(:topic_view, :chat_channel_id) do
      return nil if object.topic.topic_chat_channel.blank?
      object.topic.topic_chat_channel.chat_channel_id
    end

    on(:post_edited) do |post, _, _|
      DiscourseLivestream.handle_topic_chat_channel_creation(post.topic)
    end
    on(:topic_created) do |topic, _, _|
      DiscourseLivestream.handle_topic_chat_channel_creation(topic)
    end
  end

  on(:discourse_calendar_post_event_invitee_status_changed) do |invitee|
    topic = invitee.event.post.topic
    topic_chat_channel = topic.topic_chat_channel

    next if !topic_chat_channel

    user = User.find(invitee.user_id)
    channel = topic_chat_channel.chat_channel
    manager = Chat::ChannelMembershipManager.new(channel)

    allowed_groups = SiteSetting.livestream_chat_allowed_groups.split("|").map(&:to_i)
    user_allowed_in_chat = (allowed_groups & user.groups.ids).any?

    membership =
      if invitee.status == DiscoursePostEvent::Invitee.statuses[:going]
        user_allowed_in_chat ? manager.follow(user) : manager.unfollow(user)
      else
        manager.unfollow(user)
      end

    ::MessageBus.publish "discourse_livestream_update_livestream_chat_status",
                         Chat::UserChannelMembershipSerializer.new(membership).to_json
  end

  on(:site_setting_changed) do |name, old_val, new_val|
    if name == :livestream_chat_allowed_groups
      Jobs::RecalculateUserLivestreamChannelMemberships.new.execute
    end
  end
end
