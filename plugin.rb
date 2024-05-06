# frozen_string_literal: true

# name: discourse-livestream
# about: Plugin to add livestream functionality to Discourse
# version: 0.0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-livestream
# required_version: 2.7.0

enabled_site_setting :enable_discourse_livestream

register_asset "stylesheets/common/discourse-livestream.scss"

PLUGIN_NAME ||= "discourse-livestream".freeze

after_initialize do
  class ::WebHookEventType
    REGISTER_DEV_DAYS_CONFERENCE = 5348.freeze
    SUBMIT_SURVEY_RESPONSE = 8438.freeze
  end

  SeedFu.fixture_paths << Rails.root.join("plugins", "discourse-livestream", "db", "fixtures").to_s

  ::ActionController::Base.prepend_view_path File.expand_path("../app/views/", __FILE__)

  %w[
    ../app/controllers/discourse_livestream/conferences_controller
    ../app/controllers/discourse_livestream/conference_streams_controller
    ../app/controllers/discourse_livestream/conference_stage_sessions_controller
    ../app/controllers/discourse_livestream/conference_surveys_controller
    ../app/models/discourse_livestream/conference
    ../app/models/discourse_livestream/conference_attendee
    ../app/models/discourse_livestream/conference_stream
    ../app/models/discourse_livestream/conference_stage
    ../app/models/discourse_livestream/conference_survey
    ../app/models/discourse_livestream/conference_survey_response
    ../app/models/discourse_livestream/conference_stage_session
    ../app/serializers/discourse_livestream/conference_attendances_serializer
    ../app/serializers/discourse_livestream/conference_speaker_serializer
    ../app/serializers/discourse_livestream/conference_stage_session_serializer
    ../app/serializers/discourse_livestream/conference_stages_serializer
    ../app/serializers/discourse_livestream/conference_stream_serializer
    ../app/serializers/discourse_livestream/group_user_serializer
    ../app/serializers/discourse_livestream/conference_survey_response_serializer
    ../app/serializers/discourse_livestream/conference_survey_serializer
    ../app/models/discourse_livestream/conference_user_stage_session
    ../lib/discourse_livestream/chat_channel_extension
    ../lib/discourse_livestream/topic_extension
    ../lib/discourse_livestream/handle_chat_channel_creation
    ../lib/discourse_livestream/user_extension
    ../lib/discourse_livestream/category_extension
  ].each { |path| require File.expand_path(path, __FILE__) }

  module ::DiscourseLivestream
    USER_CUSTOM_FIELD_NAME = "dont_send_accepted_solution_notifications"

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseLivestream
    end
  end

  ::DiscourseLivestream::Engine.routes.draw do
    get "/conference" => "conferences#index"
    post "/conference/streams" => "conference_streams#create"
    get "/conference/streams/:stream_id" => "conference_streams#show"
    post "/conference/streams/:stream_id/stages/:stage_id/stage_sessions" =>
           "conference_stage_sessions#create"
    get "/conference/streams/:stream_id/stages/:stage_id/stage_sessions" =>
          "conference_stage_sessions#index"
    post "/conference/register" => "conferences#register"
    get "/conference/agenda" => "conferences#agenda"
    post "/conference/surveys/stage_session/:conference_stage_session_id/create",
         to: "conference_surveys#create"
    post "/conference/surveys/:survey_id/submit_response", to: "conference_surveys#submit_response"
  end

  Discourse::Application.routes.append { mount ::DiscourseLivestream::Engine, at: "/" }

  User.register_custom_field_type(DiscourseLivestream::USER_CUSTOM_FIELD_NAME, :boolean)
  register_editable_user_custom_field(DiscourseLivestream::USER_CUSTOM_FIELD_NAME)
  DiscoursePluginRegistry.serialized_current_user_fields << DiscourseLivestream::USER_CUSTOM_FIELD_NAME

  reloadable_patch do
    User.prepend DiscourseLivestream::UserExtension
    Category.prepend DiscourseLivestream::CategoryExtension

    Chat::Channel.prepend DiscourseLivestream::ChatChannelExtension
    Topic.prepend DiscourseLivestream::TopicExtension

    add_to_serializer(:topic_view, :chat_channel_id) { object.topic&.chat_channel&.id }

    DiscourseEvent.on(:post_edited) do |post, _, _|
      DiscourseLivestream.handle_chat_channel_creation(post.topic)
    end

    DiscourseEvent.on(:topic_created) do |topic, _, _|
      DiscourseLivestream.handle_chat_channel_creation(topic)
    end

    add_to_serializer(:site_category, :chat_channel_id) { object&.chat_channel&.chatable_id }
  end
end
