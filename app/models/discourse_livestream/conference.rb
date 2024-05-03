# frozen_string_literal: true
module DiscourseLivestream
  class Conference < ::ActiveRecord::Base
    belongs_to :category
    has_many :conference_attendees,
             class_name: "DiscourseLivestream::ConferenceAttendee",
             foreign_key: "discourse_conference_id",
             dependent: :destroy
    self.table_name = "discourse_conferences"
  end
end
