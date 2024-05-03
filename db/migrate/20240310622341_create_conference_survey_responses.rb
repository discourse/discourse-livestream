# frozen_string_literal: true
class CreateConferenceSurveyResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_conference_survey_responses do |t|
      t.integer :discourse_conference_survey_id, null: false
      t.integer :user_id, null: false
      t.integer :score
      t.text :comment

      t.timestamps
    end

    add_index :discourse_conference_survey_responses,
              :discourse_conference_survey_id,
              name: "index_dcsr_on_survey_id"
    add_index :discourse_conference_survey_responses, :user_id, name: "index_dcsr_on_user_id"
    add_foreign_key :discourse_conference_survey_responses,
                    :discourse_conference_surveys,
                    column: :discourse_conference_survey_id
    add_foreign_key :discourse_conference_survey_responses, :users, column: :user_id
  end
end
