# frozen_string_literal: true
module DiscourseLivestream
  class ConferenceStream < ActiveRecord::Base
    self.table_name = "discourse_conference_streams"
    belongs_to :conference,
               class_name: "DiscourseLivestream::Conference",
               foreign_key: "discourse_conference_id"
    has_many :conference_stages,
             class_name: "DiscourseLivestream::ConferenceStage",
             foreign_key: "discourse_conference_stream_id",
             dependent: :destroy

    validates :name, presence: true
    validates :description, presence: true
  end
end
