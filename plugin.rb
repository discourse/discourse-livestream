# frozen_string_literal: true

# name: discourse-livestream
# about: Plugin to add livestream functionality to Discourse
# version: 0.0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-livestream
# required_version: 2.7.0

enabled_site_setting :discourse_livestream_enabled

register_asset "stylesheets/common/base-common.scss"
register_asset "stylesheets/desktop/base-desktop.scss", :desktop
register_asset "stylesheets/mobile/base-mobile.scss", :mobile

after_initialize do
  module ::DiscourseLivestream
    PLUGIN_NAME = "discourse-livestream"

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseLivestream
    end
  end

  Discourse::Application.routes.append { mount ::DiscourseLivestream::Engine, at: "/" }

  require_relative "lib/discourse_livestream/topic_extension"
  require_relative "lib/discourse_livestream/chat_channel_extension"
  require_relative "lib/discourse_livestream/handle_topic_chat_channel_creation"
  require_relative "app/models/discourse_livestream/topic_chat_channel"

  reloadable_patch do
    Topic.prepend DiscourseLivestream::TopicExtension
    Chat::Channel.prepend DiscourseLivestream::ChatChannelExtension

    add_to_serializer(:topic_view, :chat_channel_id) do
      return nil if object.topic.topic_chat_channel.blank?
      object.topic.topic_chat_channel.chat_channel_id
    end

    on(:post_edited) do |post, _, _|
      DiscourseLivestream.handle_topic_chat_channel_creation(post.topic)
    end
    on(:topic_created) do |topic, _, _|
      DiscourseLivestream.handle_topic_chat_channel_creation(topic)
    end
  end
end
