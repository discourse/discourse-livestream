# frozen_string_literal: true

Fabricator(:conference_attendee, class_name: "DiscourseLivestream::ConferenceAttendee") do
  user
  conference
end
