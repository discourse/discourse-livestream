# frozen_string_literal: true

# name: discourse-livestream
# about: Plugin to add livestream functionality to Discourse
# version: 0.0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-livestream
# required_version: 2.7.0

enabled_site_setting :enable_discourse_livestream

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

  require_relative "lib/discourse_livestream/chat_channel_extension"
  require_relative "lib/discourse_livestream/topic_extension"
  require_relative "lib/discourse_livestream/handle_chat_channel_creation"

  reloadable_patch do
    Chat::Channel.prepend DiscourseLivestream::ChatChannelExtension
    Topic.prepend DiscourseLivestream::TopicExtension

    add_to_serializer(:topic_view, :chat_channel_id) { object.topic&.chat_channel&.id }

    on(:post_edited) { |post, _, _| DiscourseLivestream.handle_chat_channel_creation(post.topic) }
    on(:topic_created) { |topic, _, _| DiscourseLivestream.handle_chat_channel_creation(topic) }

    add_to_serializer(:site_category, :chat_channel_id) { object&.chat_channel&.chatable_id }
  end
end
