import Component from "@glimmer/component";
import { inject as controller } from "@ember/controller";
import { service } from "@ember/service";
import DModal from "discourse/components/d-modal";
import EmbeddableChatChannel from "../embeddable-chat-channel";

export default class MobileEmbeddableChatModal extends Component {
  @service embeddableChat;
  @controller("topic") topicController;

  get shouldRender() {
    return this.embeddableChat.canRenderChatChannel(this.topicController, true);
  }

  <template>
    <DModal
      @closeModal={{@closeModal}}
      class="livestream-chat-modal"
      @hideHeader={{true}}
    >
      <:body>
        {{#if this.shouldRender}}
          <EmbeddableChatChannel
            @chatChannelId={{this.embeddableChat.chatChannelId}}
          />
        {{/if}}
      </:body>
    </DModal>
  </template>
}
