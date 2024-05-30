# frozen_string_literal: true

module DiscourseLivestream
  module TopicExtension
    extend ActiveSupport::Concern

    prepended do
      has_one :topic_chat_channel,
              class_name: "DiscourseLivestream::TopicChatChannel",
              dependent: :destroy
    end
  end
end
