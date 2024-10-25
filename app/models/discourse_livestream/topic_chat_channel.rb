# frozen_string_literal: true

module DiscourseLivestream
  class TopicChatChannel < ActiveRecord::Base
    self.table_name = "livestream_topic_chat_channels"
    belongs_to :topic
    belongs_to :chat_channel, class_name: "Chat::Channel", dependent: :destroy
  end
end

# == Schema Information
#
# Table name: livestream_topic_chat_channels
#
#  id              :bigint           not null, primary key
#  topic_id        :integer          not null
#  chat_channel_id :bigint           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  unique_livestream_topic_chat_channels  (topic_id,chat_channel_id) UNIQUE
#
