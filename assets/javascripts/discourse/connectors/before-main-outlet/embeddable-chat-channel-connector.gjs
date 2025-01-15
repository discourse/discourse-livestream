import Component from "@glimmer/component";
import { inject as controller } from "@ember/controller";
import { service } from "@ember/service";
import EmbeddableChatChannel from "../../components/embeddable-chat-channel";

export default class EmbedableChatChannelConnector extends Component {
  @service embeddableChat;
  @service siteSettings;
  @service site;
  @controller("topic") topicController;

  get shouldRender() {
    let mobileView =
      !this.siteSettings.enable_modal_chat_on_mobile && this.site.mobileView;

    return this.embeddableChat.canRenderChatChannel(
      this.topicController,
      mobileView
    );
  }

  <template>
    {{#if this.shouldRender}}
      <EmbeddableChatChannel
        @chatChannelId={{this.embeddableChat.chatChannelId}}
      />
    {{/if}}
  </template>
}
