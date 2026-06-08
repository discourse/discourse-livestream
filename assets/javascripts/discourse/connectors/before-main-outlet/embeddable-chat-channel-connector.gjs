import Component from "@glimmer/component";
import { inject as controller } from "@ember/controller";
import { service } from "@ember/service";
import EmbeddableChatChannel from "../../components/embeddable-chat-channel";

export default class EmbedableChatChannelConnector extends Component {
  @service livestreamEmbeddableChat;
  @service siteSettings;
  @service capabilities;
  @controller("topic") topicController;

  get shouldRender() {
    const mobileViewport =
      !this.siteSettings.discourse_livestream_enable_modal_chat_on_mobile &&
      !this.capabilities.viewport.lg;

    // If the core discourse-calendar livestream is enabled, this
    // plugin should be a noop.
    if (this.siteSettings.livestream_enabled) {
      return false;
    }

    return this.livestreamEmbeddableChat.canRenderChatChannel(
      this.topicController,
      mobileViewport
    );
  }

  <template>
    {{#if this.shouldRender}}
      <EmbeddableChatChannel
        @chatChannelId={{this.livestreamEmbeddableChat.chatChannelId}}
      />
    {{/if}}
  </template>
}
