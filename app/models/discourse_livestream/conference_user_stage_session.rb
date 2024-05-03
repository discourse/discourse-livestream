# frozen_string_literal: true
module DiscourseLivestream
  class ConferenceUserStageSession < ActiveRecord::Base
    self.table_name = "conference_user_stage_sessions"

    belongs_to :user
    belongs_to :stage_session,
               class_name: "DiscourseLivestream::ConferenceStageSession",
               foreign_key: "discourse_conference_stage_session_id"
  end
end
