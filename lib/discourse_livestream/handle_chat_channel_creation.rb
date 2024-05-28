# frozen_string_literal: true
module DiscourseLivestream
  def self.handle_chat_channel_creation(topic)
    return unless SiteSetting.enable_livestream_chat
    return if topic.category.blank?
    unless Chat::Channel.exists?(
             topic_id: topic.id,
             chatable_id: topic.category.id,
             chatable_type: "Category",
           )
      if topic.category.present? &&
           topic.tags.any? { |tag| tag.name == SiteSetting.topic_livestream_tag }
        channel =
          Chat::Channel.create!(
            chatable_id: topic.category.id,
            chatable_type: "Category",
            name: topic.title,
            status: Chat::Channel.statuses[:open],
            type: "CategoryChannel",
            allow_channel_wide_mentions: true,
            topic: topic,
          )

        channel.user_chat_channel_memberships.create!(user: topic.user, following: true)
      end
    end
  end
end
