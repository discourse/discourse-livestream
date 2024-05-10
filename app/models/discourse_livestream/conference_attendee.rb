# frozen_string_literal: true
module DiscourseLivestream
  class ConferenceAttendee < ::ActiveRecord::Base
    belongs_to :user
    belongs_to :conference,
               foreign_key: "discourse_conference_id",
               class_name: "DiscourseLivestream::Conference"
    self.table_name = "discourse_conference_attendees"
  end
end
