# frozen_string_literal: true

module DiscourseLivestream 
  class TopicChatChannel < ActiveRecord::Base
    self.table_name = "topic_chat_channels"

    belongs_to :topic
  end
end
