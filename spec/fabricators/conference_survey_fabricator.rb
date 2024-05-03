# frozen_string_literal: true
Fabricator(:conference_survey, class_name: "DiscourseLivestream::ConferenceSurvey") do
  conference_stage_session
  title { sequence(:title) { |n| "Survey Title #{n}" } }
end
