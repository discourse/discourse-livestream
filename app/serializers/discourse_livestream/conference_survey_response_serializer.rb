# frozen_string_literal: true

module DiscourseLivestream
  class ConferenceSurveyResponseSerializer < ActiveModel::Serializer
    attributes :id, :score, :comment, :created_at, :updated_at
  end
end
