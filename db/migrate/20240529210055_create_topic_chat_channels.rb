# frozen_string_literal: true

class CreateTopicChatChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :topic_chat_channels do |t|
      t.integer :topic_id, null: false
      t.integer :chat_channel_id, null: false
      t.timestamps
    end

    add_index :topic_chat_channels, %i[topic_id chat_channel_id], unique: true
  end
end
