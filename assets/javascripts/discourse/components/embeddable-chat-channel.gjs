import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { inject as controller } from "@ember/controller";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import and from "truth-helpers/helpers/and";
import not from "truth-helpers/helpers/not";
import ChatChannel from "discourse/plugins/chat/discourse/components/chat-channel";

export default class EmbedableChatChannel extends Component {
  @service chatChannelsManager;
  @service currentUser;
  @service embeddableChat;
  @service appEvents;
  @service site;
  @service chatDraftsManager;
  @controller("topic") topicController;

  @tracked topicModel = null;
  @tracked topicChannelId = null;
  @tracked loadingChannel = false;

  willDestroy() {
    super.willDestroy(...arguments);
    this.chatDraftsManager.reset();
    this.embeddableChat.activeChannel = null;
  }

  @action
  async findChannel(channelId) {
    try {
      this.loadingChannel = true;
      this.embeddableChat.activeChannel = await this.chatChannelsManager.find(
        channelId
      );
    } finally {
      this.loadingChannel = false;
    }
  }

  <template>
    <div
      id="custom-chat-container"
      {{toggleClass this.embeddableChat.isMobileChatVisible 'mobile'}}
      class="chat-drawer {{unless this.siteSettings.modal_mobile_chat 'no-modal-mobile'}}"
      {{didInsert (fn this.findChannel @chatChannelId)}}
    >
      {{#if (and this.embeddableChat.activeChannel (not this.loadingChannel))}}
        <ChatChannel @channel={{this.embeddableChat.activeChannel}} />
      {{/if}}
    </div>
  </template>
}
