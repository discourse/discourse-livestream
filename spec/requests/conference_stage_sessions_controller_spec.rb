# frozen_string_literal: true
require "rails_helper"

RSpec.describe DiscourseLivestream::ConferenceStageSessionsController do
  fab!(:user)
  fab!(:category)
  fab!(:conference) { Fabricate(:conference, category: category) }
  fab!(:stream) { Fabricate(:conference_stream, conference: conference) }
  fab!(:stage) { Fabricate(:conference_stage, conference_stream: stream) }
  fab!(:admin)
  fab!(:speaker1) { Fabricate(:user, username: "jean.perez") }
  fab!(:speaker2) { Fabricate(:user, username: "alex.smith") }

  let(:valid_session_params) do
    {
      stage_session: {
        start_time: DateTime.now + 2.days,
        end_time: DateTime.now + 2.days + 2.hours,
        title: "New Session Title",
        external_id: "NewExternalID",
        speakers: "jean.perez,alex.smith",
      },
    }
  end

  let(:sessions_url) { "/conference/streams/#{stream.id}/stages/#{stage.id}/stage_sessions.json" }

  before do
    SiteSetting.enable_discourse_livestream = true
    sign_in(admin)
  end

  describe "#create" do
    context "when logged in as admin" do
      it "creates a new session and assigns speakers successfully" do
        expect { post sessions_url, params: valid_session_params }.to change(
          DiscourseLivestream::ConferenceStageSession,
          :count,
        ).by(1)
        expect(response).to have_http_status(:success)

        created_session = DiscourseLivestream::ConferenceStageSession.last
        expect(created_session.title).to eq(valid_session_params[:stage_session][:title])
        expect(created_session.speakers).to match_array([speaker1, speaker2])
      end

      it "sets the new session to live and previous session to completed" do
        initial_session =
          DiscourseLivestream::ConferenceStageSession.create!(
            title: "Initial Session",
            external_id: "InitialID",
            start_time: DateTime.now + 1.days,
            end_time: DateTime.now + 1.days + 2.hours,
            status: :live,
            stage: stage,
          )

        post sessions_url, params: valid_session_params
        expect(response).to have_http_status(:success)

        initial_session.reload
        new_session = DiscourseLivestream::ConferenceStageSession.last

        expect(initial_session.status).to eq("completed")
        expect(new_session.status).to eq("live")
      end
    end
  end

  describe "#index" do
    context "with multiple session statuses" do
      let!(:live_session) { Fabricate(:conference_stage_session, stage: stage, status: :live) }
      let!(:completed_session) do
        Fabricate(:conference_stage_session, stage: stage, status: :completed)
      end
      let!(:scheduled_session) do
        Fabricate(:conference_stage_session, stage: stage, status: :scheduled)
      end

      it "filters sessions by status" do
        get sessions_url,
            params: {
              stream_id: stream.id,
              stage_id: stage.id,
              status: "live,scheduled",
            }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)["conference_stage_sessions"] # Adjust based on actual response structure
        expect(json_response.length).to eq(2)
        statuses = json_response.map { |s| s["status"] }
        expect(statuses).to include("live", "scheduled")
        expect(statuses).not_to include("completed")
      end

      it "orders sessions by status" do
        get sessions_url, params: { stream_id: stream.id, stage_id: stage.id }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)["conference_stage_sessions"] # Use the corrected key
        expect(json_response.first["status"]).to eq("scheduled")
        expect(json_response.last["status"]).to eq("completed")
      end
    end
  end
end
