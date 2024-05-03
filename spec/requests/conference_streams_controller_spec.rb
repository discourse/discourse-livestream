# frozen_string_literal: true
require "rails_helper"

RSpec.describe DiscourseLivestream::ConferenceStreamsController do
  fab!(:admin)
  fab!(:user)
  fab!(:category)
  fab!(:conference) { Fabricate(:conference, category: category) }

  let(:valid_stream_params) do
    {
      conference_stream: {
        name: "Day 1",
        description: "First conference day",
        discourse_conference_id: conference.id,
        start_date: DateTime.now + 2.hours,
        end_date: DateTime.now + 3.hours,
      },
    }
  end

  describe "#show" do
    fab!(:conference_stream) { Fabricate(:conference_stream, conference: conference) }

    it "responds successfully with the stream data" do
      sign_in(user)
      get "/conference/streams/#{conference_stream.id}.json"
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response["conference_stream"]["name"]).to eq(conference_stream.name)
    end
  end

  describe "#create" do
    fab!(:conference_stream) { Fabricate(:conference_stream, conference: conference) }

    context "when not logged in" do
      it "requires login" do
        post "/conference/streams.json", params: valid_stream_params
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when user is part of the conference group" do
      fab!(:group)

      before do
        SiteSetting.conference_group_name = group.name
        group.add(user, automatic: true)
      end

      it "indicates the user is registered to the conference group" do
        sign_in(user)
        get "/conference/streams/#{conference_stream.id}.json"
        json_response = JSON.parse(response.body)
        expect(json_response["conference_stream"]["is_current_user_registered"]).to be true
      end
    end

    context "when user is not part of the conference group" do
      it "indicates the user is not registered to the conference group" do
        sign_in(user)
        get "/conference/streams/#{conference_stream.id}.json"
        json_response = JSON.parse(response.body)
        expect(json_response["conference_stream"]["is_current_user_registered"]).to be false
      end
    end

    context "when logged in as admin" do
      before { sign_in(admin) }

      it "creates a new stream successfully" do
        expect { post "/conference/streams.json", params: valid_stream_params }.to change(
          DiscourseLivestream::ConferenceStream,
          :count,
        ).by(1)
        expect(response).to have_http_status(:success)
        new_stream = DiscourseLivestream::ConferenceStream.last
        expect(new_stream.name).to eq(valid_stream_params[:conference_stream][:name])
      end

      it "renders an error when parameters are invalid" do
        invalid_params = valid_stream_params.deep_merge(conference_stream: { name: nil })
        post "/conference/streams.json", params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
