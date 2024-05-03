# frozen_string_literal: true

module DiscourseLivestream
  module TopicExtension
    extend ActiveSupport::Concern

    prepended { has_one :chat_channel, dependent: :destroy, class_name: "Chat::Channel" }
  end
end
