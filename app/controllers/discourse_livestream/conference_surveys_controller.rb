# frozen_string_literal: true
module ::DiscourseLivestream
  class ConferenceSurveysController < ::ApplicationController
    before_action :find_session, only: [:create]
    before_action :find_survey, only: [:submit_response]
    before_action :ensure_logged_in
    before_action :ensure_admin, only: [:create]

    def create
      survey = ConferenceSurvey.new(survey_params.merge(conference_stage_session_id: @session.id))

      if survey.save
        MessageBus.publish(
          "/new_survey",
          { session_id: @session.id, title: survey.title, survey_id: survey.id },
        )
        render json: serialize_data(survey, ConferenceSurveySerializer)
      else
        render json: { errors: survey.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def submit_response
      survey_response =
        ConferenceSurveyResponse.new(
          survey_response_params.merge(conference_survey_id: @survey.id, user_id: current_user.id),
        )
      if survey_response.save
        payload = {
          survey_response_id: survey_response.id,
          survey_id: @survey.id,
          external_session_id: @survey.external_session_id,
          comment: survey_response.comment,
          score: survey_response.score,
          username: current_user.username,
        }.to_json
        WebHook.enqueue_hooks(:voting, :submit_survey_response, payload: payload)

        render json: serialize_data(survey_response, ConferenceSurveyResponseSerializer)
      else
        render json: { errors: survey_response.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def find_survey
      @survey = ConferenceSurvey.find(params[:survey_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Survey not found" }, status: :not_found
    end

    def find_session
      @session = DiscourseLivestream::ConferenceStageSession.find(params[:conference_stage_session_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Session not found" }, status: :not_found
    end

    def survey_params
      params.require(:survey).permit(:title, :external_session_id)
    end

    def survey_response_params
      params.require(:survey_response).permit(:score, :comment)
    end
  end
end
