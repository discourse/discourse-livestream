# frozen_string_literal: true
module DiscourseLivestream
  class ConferenceSurveyResponse < ActiveRecord::Base
    self.table_name = "discourse_conference_survey_responses"

    belongs_to :conference_survey,
               class_name: "ConferenceSurvey",
               foreign_key: "conference_survey_id"
    belongs_to :user

    validates :comment, length: { maximum: 1000 }
    validates :score, presence: true, numericality: { only_integer: true }
  end
end
