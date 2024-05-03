#frozen_string_literal: true

module DiscourseLivestream
  class ConferenceAttendancesSerializer < ActiveModel::Serializer
    attributes :id,
               :selected_conference,
               :company,
               :country,
               :title,
               :discourse_conference_id,
               :category_id,
               :created_at

    def category_id
      object.conference.category_id
    end
  end
end
