# frozen_string_literal: true
class AddChatChannelToTopics < ActiveRecord::Migration[7.0]
  def change
    add_column :topics, :chat_channel_id, :integer
  end
end
