# frozen_string_literal: true

module DiscourseLivestream
  class ConferenceSurveySerializer < ActiveModel::Serializer
    attributes :id, :external_session_id, :title, :created_at, :updated_at

    has_one :survey_response, embed: :objects

    def survey_response
      object.survey_responses.where(user_id: scope.current_user.id).last
    end
  end
end
