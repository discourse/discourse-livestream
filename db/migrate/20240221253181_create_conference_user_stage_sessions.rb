# frozen_string_literal: true
class CreateConferenceUserStageSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_conference_user_stage_sessions do |t|
      t.integer :user_id, null: false
      t.integer :discourse_conference_stage_session_id, null: false

      t.timestamps
    end

    add_index :discourse_conference_user_stage_sessions, :user_id, name: "index_sps_user_id"
    add_index :discourse_conference_user_stage_sessions,
              :discourse_conference_stage_session_id,
              name: "index_sps_stage_session_id"

    add_foreign_key :discourse_conference_user_stage_sessions, :users, column: :user_id
    add_foreign_key :discourse_conference_user_stage_sessions,
                    :discourse_conference_stage_sessions,
                    column: :discourse_conference_stage_session_id
  end
end
