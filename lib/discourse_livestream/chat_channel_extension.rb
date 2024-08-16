# frozen_string_literal: true

module DiscourseLivestream
  module ChatChannelExtension
    extend ActiveSupport::Concern

    prepended do
      has_one :topic_chat_channel,
              class_name: "DiscourseLivestream::TopicChatChannel",
              dependent: :destroy,
              foreign_key: :chat_channel_id
    end
  end
end
