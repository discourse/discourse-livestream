# frozen_string_literal: true

class AlterLivestreamIdsToBigint < ActiveRecord::Migration[7.1]
  def up
    change_column :livestream_topic_chat_channels, :chat_channel_id, :bigint
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
