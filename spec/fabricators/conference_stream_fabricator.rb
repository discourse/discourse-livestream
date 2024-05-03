# frozen_string_literal: true
Fabricator(:conference_stream, class_name: "DiscourseLivestream::ConferenceStream") do
  conference
  name { sequence(:name) { |n| "Stream Name #{n}" } }
  description { "This is a detailed description of what the stream covers." }
  start_date { 1.week.from_now }
  end_date { 1.week.from_now + 1.hour }
end
