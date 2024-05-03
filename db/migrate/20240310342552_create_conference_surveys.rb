# frozen_string_literal: true
class CreateConferenceSurveys < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_conference_surveys do |t|
      t.integer :conference_stage_session_id, null: false
      t.string :title

      t.timestamps
    end

    add_index :discourse_conference_surveys,
              :discourse_conference_stage_session_id,
              name: "index_dcs_on_session_id"
    add_foreign_key :discourse_conference_surveys,
                    :discourse_conference_stage_sessions,
                    column: :discourse_conference_stage_session_id
  end
end
