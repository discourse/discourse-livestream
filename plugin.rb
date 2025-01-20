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
require_relative "lib/discourse_livestream/register_helpers"
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

  def user_allowed_in_livestream_chat?(user)
    allowed_groups = SiteSetting.livestream_chat_allowed_groups.split("|").map(&:to_i)
    (allowed_groups & user.groups.ids).any?
  end

  on(:discourse_post_event_invitee_status_changed) do |invitee|
    topic = invitee.post.topic

    if (topic_chat_channel = topic.topic_chat_channel) &&
         invite.status == DiscoursePostEvent::Invitee.statuses[:going]
      user = User.find(user_id)
      channel = topic_chat_channel.chat_channel
      ChannelMembershipManager.new(channel)

      if user_allowed_in_livestream_chat?(user)
        manager.follow(user) if !membership.following
      else
        manager.unfollow(user) if membership.following
      end
    end
  end

  on(:site_setting_changed) do |name, old_val, new_val|
    Jobs::RecalculateUserLivestreamChannelMemberships.new.execute
  end

  # register_modifier(:channel_memberships) do |f, user|
  #   if SiteSetting.calendar_enabled && SiteSetting.discourse_post_event_enabled
  #     channel_memberships =
  #       Chat::UserChatChannelMembership
  #         .joins(chat_channel: { livestream_topic_chat_channel: :topic })
  #         .where(user: user)
  #         .includes(chat_channel: { livestream_topic_chat_channel: { topic: { posts: :event } } })

  #     user_id = user.id
  #     going = DiscoursePostEvent::Invitee.statuses[:going]

  #     query = <<~SQL
  #       WITH event_posts AS (
  #         SELECT p.*
  #         FROM posts p
  #         JOIN discourse_post_event_invitees dpei ON p.id = dpei.post_id
  #         WHERE dpei.status = #{going}
  #           AND dpei.user_id = #{user_id}
  #       )
  #       SELECT t.*
  #       FROM topics t
  #       JOIN event_posts ep ON t.id = ep.topic_id
  #     SQL

  #     user_attending_events = Topic.find_by_sql(query)

  #     channel_memberships.each do |membership|
  #       topic_chat_channel = membership.chat_channel.livestream_topic_chat_channel
  #       next if !topic_chat_channel

  #       invitees = user_attending_events.select { |topic| topic.id == topic_chat_channel.topic.id }
  #       is_going = invitees.any?
  #       next if !is_going

  #       manager = Chat::ChannelMembershipManager.new(membership.chat_channel)

  #       if user_allowed_in_livestream_chat?(user)
  #         manager.follow(user) if !membership.following
  #       else
  #         manager.unfollow(user) if membership.following
  #       end
  #     end
  #   end

  #   Chat::UserChatChannelMembership.where(user: user)
  # end

  # register_modifier(:follow_modifier) do |f, channel, user, membership, object|
  #   topic_chat_channel = DiscourseLivestream::TopicChatChannel.find_by(chat_channel_id: channel.id)

  #   user_allowed_in_topic_chat_channels = user_allowed_in_livestream_chat?(user)

  #   ActiveRecord::Base.transaction do
  #     if topic_chat_channel && !user_allowed_in_topic_chat_channels
  #       if membership.following
  #         membership.update!(following: false)
  #         object.recalculate_user_count
  #       end
  #     else
  #       if membership.new_record?
  #         membership.save!
  #         object.recalculate_user_count
  #       elsif !membership.following
  #         membership.update!(following: true)
  #         object.recalculate_user_count
  #       end
  #     end
  #   end

  #   membership
  # end
end
