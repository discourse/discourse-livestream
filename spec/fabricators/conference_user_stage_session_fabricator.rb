# frozen_string_literal: true
Fabricator(
  :conference_user_stage_session,
  class_name: "DiscourseLivestream::ConferenceUserStageSession",
) do
  user
  conference_stage_session
end
