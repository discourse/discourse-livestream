# frozen_string_literal: true

module DiscourseLivestream
  class ::ConferenceStagesSerializer < ActiveModel::Serializer
    attributes :id, :name, :slug, :created_at, :updated_at

    has_one :live_stage_session, serializer: ::ConferenceStageSessionSerializer

    def live_stage_session
      object.stage_sessions.live.first
    end
  end
end
