# frozen_string_literal: true

describe "Discourse Livestream - Topic Livestream - Desktop - Authenticated", type: :system, js: true do
  fab!(:current_user) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:livestream_tag) { Fabricate(:tag, name: "livestream") }
  fab!(:category) 
  let(:topic_page) { PageObjects::Pages::Topic.new }
  let(:composer) { PageObjects::Components::Composer.new }

  before do
    SiteSetting.discourse_livestream_enabled = true
    sign_in(current_user)
  end

  context "topic creation" do
    it "creates a chat channel for livestream topics" do
      visit("/latest")
      topic_page.open_new_topic

      composer.fill_title("Creating a livestream topic")
      tag_chooser = PageObjects::Components::SelectKit.new(".mini-tag-chooser")
      tag_chooser.expand
      tag_chooser.select_row_by_name(livestream_tag.name)
      composer.fill_content("The content for my livestream topic")
      composer.create

      expect(topic_page).to have_css("#custom-chat-container")
      expect(topic_page).to have_css(".chat-channel-preview-card")
    end

    it "does not create a chat channel for regular topics" do
      visit("/latest")
      topic_page.open_new_topic

      composer.fill_title("Creating a regular topic")
      composer.fill_content("The content for my regular topic")
      composer.create

      expect(topic_page).not_to have_css("#custom-chat-container")
    end
  end
end

describe "Discourse Livestream - Topic Livestream - Mobile - Authenticated", type: :system, js: true, mobile: true do
  fab!(:current_user) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:livestream_tag) { Fabricate(:tag, name: "livestream") }
  fab!(:category) 
  fab!(:livestream_topic) { Fabricate(:topic, user: current_user, category: category) }
  fab!(:topic) { Fabricate(:topic, category: category) }
  let(:topic_page) { PageObjects::Pages::Topic.new }

  before do
    SiteSetting.discourse_livestream_enabled = true
    sign_in(current_user)
  end

  context "topic view" do
    it "does not display livestream chat icon on regular topics" do
      topic_page.visit_topic(topic)
      expect(topic_page).to have_css(".chat-header-icon")
    end

    it "displays the livestream chat icon on livestream topics" do
      topic_page.visit_topic(livestream_topic)
      expect(topic_page).not_to have_css(".chat-header-icon")
    end
  end
end
