# frozen_string_literal: true

Fabricator(:post_event_invitee, from: "DiscoursePostEvent::Invitee") do
  event { |attrs| attrs[:event] }
  user { |attrs| attrs[:user] }
  status { |attrs| attrs[:status] || nil }
end
