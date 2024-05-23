import Component from "@glimmer/component";
import EmbeddableChatChannel from "../embeddable-chat-channel";
import DModal from "discourse/components/d-modal";
import i18n from "discourse-common/helpers/i18n";
import { inject as service } from "@ember/service";
import { inject as controller } from "@ember/controller";

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
