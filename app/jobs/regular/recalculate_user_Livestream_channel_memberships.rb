# frozen_string_literal: true

module Jobs
  class RecalculateUserLivestreamChannelMemberships < ::Jobs::Base
    def execute(args)
      if SiteSetting.calendar_enabled && SiteSetting.discourse_post_event_enabled &&
           SiteSetting.discourse_livestream_enabled
        topic_chat_channels =
          TopicChatChannel.includes(:chat_channel, :user_chat_channel_memberships)

        topic_chat_channels.each do |topic_chat_channel|
          membership =
            Chat::UserChatChannelMemberships.find_by(
              chat_channel_id: topic_chat_channel.chat_channel_id,
            )

          channel = topic_chat_channel.chat_channel

          manager = Chat::ChatMembershipManager.new(channel)

          ActiveRecord::Base.transaction do
            if membership.following && !user_allowed_in_topic_chat_channels
              membership.update!(following: false)
              manager.recalculate_user_count
            else
              !membership.following && user_allowed_in_topic_chat_channels

              membership.update!(following: true)
              manager.recalculate_user_count
            end
          end

          # ActiveRecord::Base.transaction do
          #   if user_allowed_in_livestream_chat?(user) && membership.following == true
          #     membership.update!(following: true)
          #     recalculate_user_count
          #   else
          #     manager.unfollow(user) if membership.following
          #   end
          # end

          # topic_chat_channel.chat_channel.user_chat_channel_memberships
        end

        # Chat::UserChatChannelMembership.joins(:topic_chat_channel).
      end
    end

    def user_allowed_in_livestream_chat?(user)
      allowed_groups = SiteSetting.livestream_chat_allowed_groups.split("|").map(&:to_i)
      (allowed_groups & user.groups.ids).any?
    end
  end
end
