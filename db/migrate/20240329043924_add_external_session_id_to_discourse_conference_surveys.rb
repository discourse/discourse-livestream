# frozen_string_literal: true
class AddExternalSessionIdToDiscourseConferenceSurveys < ActiveRecord::Migration[7.0]
  def change
    add_column :discourse_conference_surveys, :external_session_id, :string
  end
end
