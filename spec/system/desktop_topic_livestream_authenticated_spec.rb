# frozen_string_literal: true

describe "Discourse Livestream - Topic Livestream - Desktop - Authenticated", type: :system do
  fab!(:current_user) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:category)
  fab!(:livestream_tag) { Fabricate(:tag, name: "livestream") }
  let(:topic_page) { PageObjects::Pages::Topic.new }
  let(:composer) { PageObjects::Components::Composer.new }
  let(:topic_livestream) { PageObjects::Pages::TopicLivestream.new }

  before do
    SiteSetting.discourse_livestream_enabled = true
    sign_in(current_user)
  end

  context "when in a topic view" do
    it "creates a chat channel for livestream topics" do
      topic_livestream.create_livestream_topic(composer, topic_page, livestream_tag)

      expect(topic_page).to have_css("#custom-chat-container")
      expect(topic_page).to have_css("#custom-chat-container .chat-channel-preview-card")
    end

    it "does not create a chat channel for regular topics" do
      topic_livestream.create_regular_topic(composer, topic_page)

      expect(topic_page).not_to have_css("#custom-chat-container")
    end
  end
end
