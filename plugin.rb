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

  register_modifier(:list_user_channels_modifier) do |f, user|
    user_livestream_chat_channel_memberships =
      Chat::UserChatChannelMembership
        .joins(chat_channel: { livestream_topic_chat_channel: :topic })
        .where(user: user)
        .includes(chat_channel: { livestream_topic_chat_channel: :topic })

    user_allowed_groups = SiteSetting.livestream_chat_allowed_groups.split("|").map(&:to_i)
    user_group_ids = user.groups.ids
    user_allowed_in_topic_chat_channels = (user_allowed_groups & user_group_ids).any?

    if SiteSetting.calendar_enabled && SiteSetting.discourse_post_event_enabled
      user_livestream_chat_channel_memberships.each do |membership|
        topic_chat_channel = membership.chat_channel.livestream_topic_chat_channel
        next unless topic_chat_channel

        event_invitee =
          topic_chat_channel.topic.posts.first&.event&.invitees&.find_by(user_id: user.id)
        next unless event_invitee

        invitee_status = event_invitee.status
        is_going = invitee_status == DiscoursePostEvent::Invitee.statuses[:going]
        if user_allowed_in_topic_chat_channels && is_going && !membership.following
          Chat::ChannelMembershipManager.new(membership.chat_channel).follow(user)
        elsif !user_allowed_in_topic_chat_channels && is_going && membership.following
          Chat::ChannelMembershipManager.new(membership.chat_channel).unfollow(user)
        end
      end
    end
    Chat::UserChatChannelMembership.where(user: user)
  end

  register_modifier(:follow_modifier) do |f, channel, user, membership, object|
    topic_chat_channel = DiscourseLivestream::TopicChatChannel.find_by(chat_channel_id: channel.id)

    user_allowed_groups = SiteSetting.livestream_chat_allowed_groups.split("|").map(&:to_i)
    user_group_ids = user.groups.pluck("groups.id")
    user_allowed_in_topic_chat_channels = (user_allowed_groups & user_group_ids).any?
    if topic_chat_channel && !user_allowed_in_topic_chat_channels
      ActiveRecord::Base.transaction do
        if membership.following
          membership.update!(following: false)
          object.recalculate_user_count
        end
      end
    else
      ActiveRecord::Base.transaction do
        if membership.new_record?
          membership.save!
          object.recalculate_user_count
        elsif !membership.following
          membership.update!(following: true)
          object.recalculate_user_count
        end
      end
    end
    membership
  end
end
