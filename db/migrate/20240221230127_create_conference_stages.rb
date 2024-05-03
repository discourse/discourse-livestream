# frozen_string_literal: true
class CreateConferenceStages < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_conference_stages do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.string :name
      t.string :slug
      t.string :description
      t.integer :discourse_conference_stream_id, null: false

      t.timestamps
    end

    add_foreign_key :discourse_conference_stages, :discourse_conference_streams
  end
end
