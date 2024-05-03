# frozen_string_literal: true

module DiscourseLivestream
  class ::ConferenceStageSessionSerializer < ActiveModel::Serializer
    attributes :id, :hash, :title, :external_id, :description, :start_time, :end_time, :status

    def hash
      Digest::MD5.hexdigest(scope.current_user.username)
    end

    has_one :survey, embed: :objects

    def survey
      object.surveys.last
    end

    has_one :stage
    has_many :speakers, serializer: ::ConferenceSpeakerSerializer, embed: :objects
  end
end
