# frozen_string_literal: true
require "rails_helper"

describe DiscourseLivestream::ConferencesController do
  fab!(:user)
  fab!(:category)
  fab!(:group)

  before do
    SiteSetting.conference_category_id = category.id
    SiteSetting.conference_group_name = group.name
    DiscourseLivestream::Conference.create!(category: category)
  end

  describe "#index" do
    it "responds successfully" do
      get "/conference"
      expect(response.status).to eq(200)
    end
  end

  describe "#register" do
    context "when not logged in" do
      it "raises a NotLoggedIn error" do
        post "/conference/register.json"
        expect(response.status).to eq(403)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      context "with a valid conference category" do
        it "registers the user for the conference and sends a webhook" do
          expect(DiscourseLivestream::ConferenceAttendee.count).to eq(0)
          WebHook.expects(:enqueue_hooks).times(1)
          post "/conference/register.json", params: { data: { some_key: "some_value" } }
          expect(response.status).to eq(200)
          expect(response.parsed_body["success"]).to eq("OK")
          expect(DiscourseLivestream::ConferenceAttendee.count).to eq(1)
        end
      end

      context "when conference category does not exist" do
        it "renders an error" do
          SiteSetting.conference_category_id = 658
          WebHook.expects(:enqueue_hooks).times(0)
          post "/conference/register.json", params: { data: { some_key: "some_value" } }
          expect(response.status).to eq(404)
        end
      end
    end
  end
end
