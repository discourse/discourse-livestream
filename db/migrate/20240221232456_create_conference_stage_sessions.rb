# frozen_string_literal: true
class CreateConferenceStageSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_conference_stage_sessions do |t|
      t.integer :discourse_conference_stage_id, null: false
      t.integer :status, default: 0
      t.string :title
      t.string :external_id
      t.datetime :start_time
      t.datetime :end_time
      t.datetime :ended_at
      t.string :description
      t.timestamps
    end

    add_foreign_key :discourse_conference_stage_sessions, :discourse_conference_stages
  end
end
