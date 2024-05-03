# frozen_string_literal: true
Fabricator(:conference_stage, class_name: "DiscourseLivestream::ConferenceStage") do
  conference_stream
  name { sequence(:name) { |n| "Stage Name #{n}" } }
  description { "Description of what this stage is about." }
  start_date { 1.week.from_now }
  end_date { 1.week.from_now + 1.hour }
  slug { sequence(:slug) { |n| "stage-slug-#{n}" } }
end
