# frozen_string_literal: true
require "rails_helper"

RSpec.describe DiscourseLivestream::ConferenceSurveysController do
  fab!(:admin)
  fab!(:user)
  fab!(:category)
  fab!(:conference) { Fabricate(:conference, category: category) }
  fab!(:stream) { Fabricate(:conference_stream, conference: conference) }
  fab!(:stage) { Fabricate(:conference_stage, conference_stream: stream) }
  fab!(:conference_stage_session) { Fabricate(:conference_stage_session, stage: stage) }
  fab!(:survey) do
    Fabricate(:conference_survey, conference_stage_session: conference_stage_session)
  end

  let(:valid_survey_params) do
    {
      survey: {
        title: "Session Feedback",
        external_session_id: "ExtSession123",
      },
      conference_stage_session_id: conference_stage_session.id,
    }
  end

  let(:valid_survey_response_params) do
    { survey_response: { score: 5, comment: "Great session!" }, survey_id: survey.id }
  end

  describe "#create" do
    context "when logged in as admin" do
      before { sign_in(admin) }

      it "creates a new survey successfully" do
        expect {
          post "/conference/surveys/stage_session/#{conference_stage_session.id}/create.json",
               params: {
                 survey: valid_survey_params[:survey],
               }
        }.to change(DiscourseLivestream::ConferenceSurvey, :count).by(1)
        expect(response).to have_http_status(:success)
        new_survey = DiscourseLivestream::ConferenceSurvey.last
        expect(new_survey.title).to eq("Session Feedback")
      end

      it "renders an error when parameters are invalid" do
        invalid_params = { survey: valid_survey_params[:survey].merge(title: nil) }
        post "/conference/surveys/stage_session/#{conference_stage_session.id}/create.json",
             params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when not logged in as admin" do
      before { sign_in(user) }

      it "does not allow survey creation" do
        post "/conference/surveys/stage_session/#{conference_stage_session.id}/create.json",
             params: valid_survey_params
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#submit_response" do
    before { sign_in(user) }

    it "submits a survey response successfully" do
      expect {
        post "/conference/surveys/#{survey.id}/submit_response.json",
             params: valid_survey_response_params
      }.to change(DiscourseLivestream::ConferenceSurveyResponse, :count).by(1)
      expect(response).to have_http_status(:success)
      new_response = DiscourseLivestream::ConferenceSurveyResponse.last
      expect(new_response.comment).to eq("Great session!")
    end

    it "renders an error when parameters are invalid" do
      invalid_params = valid_survey_response_params.deep_merge(survey_response: { score: nil })
      post "/conference/surveys/#{survey.id}/submit_response.json", params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
