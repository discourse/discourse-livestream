# frozen_string_literal: true
module DiscourseLivestream
  class ::ConferenceStreamSerializer < ActiveModel::Serializer
    attributes :id,
               :is_current_user_registered,
               :name,
               :description,
               :start_date,
               :end_date,
               :created_at,
               :updated_at

    has_many :conference_stages, serializer: ::ConferenceStagesSerializer, embed: :objects

    def is_current_user_registered
      Array.wrap(scope.current_user&.groups).include?(@options[:conference_group])
    end
  end
end
