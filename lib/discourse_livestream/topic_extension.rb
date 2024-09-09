# frozen_string_literal: true

module DiscourseLivestream
  module TopicExtension
    extend ActiveSupport::Concern

    prepended do
      has_one :topic_chat_channel,
              class_name: "DiscourseLivestream::TopicChatChannel",
              dependent: :destroy

      after_update do
        if topic_chat_channel&.chat_channel&.chatable_id != category_id
          topic_chat_channel.chat_channel.update!(chatable_id: category_id)
        end
      end
    end
  end
end
