# frozen_string_literal: true
Fabricator(:conference_stage_session, class_name: "DiscourseLivestream::ConferenceStageSession") do
  stage
  title { sequence(:title) { |n| "Session Title #{n}" } }
  description { "This session will cover XYZ topics." }
  start_time { 1.week.from_now }
  end_time { 1.week.from_now + 1.hour }
  status { DiscourseLivestream::ConferenceStageSession.statuses[:scheduled] }
  external_id { sequence(:external_id) { |n| "external-id-#{n}" } }
end
