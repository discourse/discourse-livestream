# frozen_string_literal: true

module DiscourseLivestream
  def self.handle_topic_chat_channel_creation(topic)
    return if topic.category.blank?
    return if DiscourseLivestream::TopicChatChannel.exists?(topic_id: topic.id)
    return if topic.tags.blank? || topic.tags.none? { |tag| tag.name == "livestream" }

    channel =
      Chat::Channel.create!(
        chatable_id: topic.category.id,
        chatable_type: "Category",
        name: topic.title,
        status: Chat::Channel.statuses[:open],
        type: "CategoryChannel",
        allow_channel_wide_mentions: true,
      )

    DiscourseLivestream::TopicChatChannel.create!(topic: topic, chat_channel: channel)
    channel.user_chat_channel_memberships.create!(user: topic.user, following: false)
  end
end
