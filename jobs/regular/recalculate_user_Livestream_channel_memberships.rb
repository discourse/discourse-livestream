module Jobs
  class RecalculateUserLivestreamChannelMemberships < ::Jobs::Base
    def execute
      if !SiteSetting.calendar_enabled && !SiteSetting.discourse_post_event_enabled &&
           !SiteSetting.discourse_livestream_enabled
        return
      end

      going = DiscoursePostEvent::Invitee.statuses[:going]
      query = <<~SQL
      WITH attending_users AS (
        SELECT u.*
        FROM discourse_post_event_invitees dpei
        JOIN users u ON dpei.user_id = u.id
        WHERE dpei.status = #{going}
      )
      SELECT uccm.*
        FROM livestream_topic_chat_channels ltcc
        JOIN chat_channels cc ON cc.id = ltcc.chat_channel_id
        JOIN user_chat_channel_memberships uccm ON cc.id = uccm.chat_channel_id
        JOIN attending_users au ON au.id = uccm.user_id
      SQL

      memberships = ::Chat::UserChatChannelMembership.find_by_sql(query)

      memberships.each do |membership|
        user = membership.user
        ActiveRecord::Base.transaction do
          if membership.following && !user_allowed_in_livestream_chat?(user)
            membership.update!(following: false)
            ::Chat::ChannelMembershipManager.new(membership.chat_channel).recalculate_user_count
          elsif !membership.following && user_allowed_in_livestream_chat?(user)
            membership.update!(following: true)
            ::Chat::ChannelMembershipManager.new(membership.chat_channel).recalculate_user_count
          end
        end

        ::MessageBus.publish "update_livestream_chat_status",
                             ::Chat::UserChannelMembershipSerializer.new(membership.reload).to_json
      end
    end

    private

    def user_allowed_in_livestream_chat?(user)
      allowed_groups = SiteSetting.livestream_chat_allowed_groups.split("|").map(&:to_i)
      (allowed_groups & user.groups.ids).any?
    end
  end
end
