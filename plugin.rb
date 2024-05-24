# frozen_string_literal: true

# name: discourse-livestream
# about: Plugin to add livestream functionality to Discourse
# version: 0.0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-livestream
# required_version: 2.7.0

enabled_site_setting :enable_discourse_livestream

register_asset "stylesheets/common/discourse-livestream.scss"

after_initialize do
  module ::DiscourseLivestream
    PLUGIN_NAME = "discourse-livestream"
    USER_CUSTOM_FIELD_NAME = "dont_send_accepted_solution_notifications"

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseLivestream
    end
  end

  WebHookEventType.const_set(:REGISTER_DEV_DAYS_CONFERENCE, 5348)
  WebHookEventType.const_set(:SUBMIT_SURVEY_RESPONSE, 8438)

  SeedFu.fixture_paths << Rails.root.join("plugins", "discourse-livestream", "db", "fixtures").to_s

  ::ActionController::Base.prepend_view_path File.expand_path("../app/views/", __FILE__)

  require_relative "app/controllers/discourse_livestream/conferences_controller"
  require_relative "app/controllers/discourse_livestream/conference_streams_controller"
  require_relative "app/controllers/discourse_livestream/conference_stage_sessions_controller"
  require_relative "app/controllers/discourse_livestream/conference_surveys_controller"
  require_relative "app/models/discourse_livestream/conference"
  require_relative "app/models/discourse_livestream/conference_attendee"
  require_relative "app/models/discourse_livestream/conference_stream"
  require_relative "app/models/discourse_livestream/conference_stage"
  require_relative "app/models/discourse_livestream/conference_survey"
  require_relative "app/models/discourse_livestream/conference_survey_response"
  require_relative "app/models/discourse_livestream/conference_stage_session"
  require_relative "app/serializers/discourse_livestream/conference_attendances_serializer"
  require_relative "app/serializers/discourse_livestream/conference_speaker_serializer"
  require_relative "app/serializers/discourse_livestream/conference_stage_session_serializer"
  require_relative "app/serializers/discourse_livestream/conference_stages_serializer"
  require_relative "app/serializers/discourse_livestream/conference_stream_serializer"
  require_relative "app/serializers/discourse_livestream/group_user_serializer"
  require_relative "app/serializers/discourse_livestream/conference_survey_response_serializer"
  require_relative "app/serializers/discourse_livestream/conference_survey_serializer"
  require_relative "app/models/discourse_livestream/conference_user_stage_session"
  require_relative "lib/discourse_livestream/chat_channel_extension"
  require_relative "lib/discourse_livestream/topic_extension"
  require_relative "lib/discourse_livestream/handle_chat_channel_creation"
  require_relative "lib/discourse_livestream/user_extension"
  require_relative "lib/discourse_livestream/category_extension"

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
    post "/conference/surveys/stage_session/:discourse_conference_stage_session_id/create",
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

    on(:post_edited) { |post, _, _| DiscourseLivestream.handle_chat_channel_creation(post.topic) }

    on(:topic_created) { |topic, _, _| DiscourseLivestream.handle_chat_channel_creation(topic) }

    add_to_serializer(:site_category, :chat_channel_id) { object&.chat_channel&.chatable_id }
  end
end
