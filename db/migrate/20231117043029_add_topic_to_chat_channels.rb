# frozen_string_literal: true
class AddTopicToChatChannels < ActiveRecord::Migration[7.0]
  def change
    add_column :chat_channels, :topic_id, :integer
  end
end
