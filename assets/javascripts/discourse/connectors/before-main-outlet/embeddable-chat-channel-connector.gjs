import Component from "@glimmer/component";
import EmbeddableChatChannel from "../../components/embeddable-chat-channel";
import { inject as service } from "@ember/service";
import { inject as controller } from "@ember/controller";

export default class EmbedableChatChannelConnector extends Component {
  @service embeddableChat;
  @controller("topic") topicController;

  get shouldRender() {
    return this.embeddableChat.canRenderChatChannel(this.topicController);
  }

  <template>
    {{#if this.shouldRender}}
      <EmbeddableChatChannel
        @chatChannelId={{this.embeddableChat.chatChannelId}}
      />
    {{/if}}
  </template>
}
