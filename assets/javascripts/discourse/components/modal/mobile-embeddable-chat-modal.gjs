import Component from "@glimmer/component";
import { inject as controller } from "@ember/controller";
import { inject as service } from "@ember/service";
import DModal from "discourse/components/d-modal";
import i18n from "discourse-common/helpers/i18n";
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
      @title={{i18n "discourse_livestream.chat.title"}}
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
