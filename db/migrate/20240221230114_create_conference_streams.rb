# frozen_string_literal: true
class CreateConferenceStreams < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_conference_streams do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.string :name
      t.string :description
      t.integer :discourse_conference_id, null: false

      t.timestamps
    end

    add_foreign_key :discourse_conference_streams, :conferences
  end
end
