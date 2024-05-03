# frozen_string_literal: true

module DiscourseLivestream
  class ::GroupUserSerializer
    has_many :conference_attendances, serializer: ConferenceAttendancesSerializer, embed: :objects

    def conference_attendances
      user&.conference_attendances
    end
  end
end
