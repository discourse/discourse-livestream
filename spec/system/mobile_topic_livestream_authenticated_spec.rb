# frozen_string_literal: true

describe "Discourse Livestream - Topic Livestream - Mobile - Authenticated",
         type: :system,
         mobile: true do
  fab!(:current_user) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:livestream_tag) { Fabricate(:tag, name: "livestream") }
  fab!(:category)
  let(:topic_page) { PageObjects::Pages::Topic.new }
  let(:composer) { PageObjects::Components::Composer.new }
  let(:topic_livestream) { PageObjects::Pages::TopicLivestream.new }

  before do
    SiteSetting.discourse_livestream_enabled = true
    sign_in(current_user)
  end

  context "when in a topic view" do
    it "does not display livestream chat icon on regular topics" do
      topic_livestream.create_regular_topic(composer, topic_page)

      expect(topic_page).to have_css(".chat-header-icon")
      expect(topic_page).not_to have_css(".livestream-header-icon")
    end

    it "displays the livestream chat icon on livestream topics" do
      topic_livestream.create_livestream_topic(composer, topic_page, livestream_tag)

      expect(topic_page).not_to have_css(".chat-header-icon")
      expect(topic_page).to have_css(".livestream-header-icon")
    end

    it "opens the chat channel and displays the preview after clicking the header icon" do
      topic_livestream.create_livestream_topic(composer, topic_page, livestream_tag)

      find(".livestream-header-icon").click
      expect(topic_page).to have_css("#custom-chat-container")
      expect(topic_page).to have_css(".chat-channel-preview-card")
    end
  end
end
