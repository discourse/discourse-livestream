# frozen_string_literal: true
module DiscourseLivestream
  class ConferenceSurvey < ActiveRecord::Base
    self.table_name = "discourse_conference_surveys"

    belongs_to :conference_stage_session,
               class_name: "DiscourseLivestream::ConferenceStageSession",
               foreign_key: "discourse_conference_stage_session_id"
    has_many :survey_responses,
             class_name: "ConferenceSurveyResponse",
             foreign_key: "discourse_conference_survey_id",
             dependent: :destroy

    validates :title, presence: true
  end
end
