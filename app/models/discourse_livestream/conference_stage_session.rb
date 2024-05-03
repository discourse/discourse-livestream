# frozen_string_literal: true
module DiscourseLivestream
  class ConferenceStageSession < ::ActiveRecord::Base
    self.table_name = "discourse_conference_stage_sessions"

    enum status: { scheduled: 0, live: 1, completed: 2 }
    belongs_to :stage,
               class_name: "DiscourseLivestream::ConferenceStage",
               foreign_key: "discourse_conference_stage_id"

    has_many :user_stage_sessions,
             class_name: "DiscourseLivestream::ConferenceUserStageSession",
             foreign_key: "discourse_conference_stage_session_id",
             dependent: :destroy
    has_many :speakers, through: :user_stage_sessions, source: :user

    has_many :surveys,
             class_name: "DiscourseLivestream::ConferenceSurvey",
             foreign_key: "conference_stage_session_id",
             dependent: :destroy

    class << self
      def live_sessions
        DiscourseLivestream::ConferenceStageSession.live
      end
    end
  end
end
