# frozen_string_literal: true

Fabricator(
  :discourse_livestream_topic_chat_channel,
  from: "DiscourseLivestream::TopicChatChannel",
) do
  topic
  chat_channel
end
