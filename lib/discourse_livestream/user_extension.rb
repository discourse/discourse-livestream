# frozen_string_literal: true
module DiscourseLivestream
  module UserExtension
    extend ActiveSupport::Concern

    prepended do
      has_many :conference_attendances,
               class_name: "DiscourseLivestream::ConferenceAttendee",
               foreign_key: "user_id",
               dependent: :destroy
      has_many :user_stage_sessions, class_name: "DiscourseLivestream::ConferenceUserStageSession"
      has_many :stage_sessions, through: :user_stage_sessions
    end
  end
end
