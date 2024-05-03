# frozen_string_literal: true
module DiscourseLivestream
  class ConferenceStage < ActiveRecord::Base
    self.table_name = "discourse_conference_stages"

    belongs_to :conference_stream,
               class_name: "DiscourseLivestream::ConferenceStream",
               foreign_key: "discourse_conference_stream_id"
    has_many :stage_sessions,
             class_name: "DiscourseLivestream::ConferenceStageSession",
             foreign_key: "discourse_conference_stage_id",
             dependent: :destroy

    has_many :user_stage_sessions, through: :stage_sessions
    has_many :speakers, through: :user_stage_sessions, source: :user
  end
end
