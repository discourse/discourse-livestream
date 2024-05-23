import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { inject as controller } from "@ember/controller";
import { inject as service } from "@ember/service";
import ChatChannel from "discourse/plugins/chat/discourse/components/chat-channel";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import and from "truth-helpers/helpers/and";
import { fn } from "@ember/helper";
import not from "truth-helpers/helpers/not";
import { action } from "@ember/object";

export default class EmbedableChatChannel extends Component {
  @service chatChannelsManager;
  @service currentUser;
  @service embeddableChat;
  @service appEvents;
  @service site;
  @service chatChannelsManager;
  @controller("topic") topicController;

  @tracked topicModel = null;
  @tracked topicChannelId = null;
  @tracked loadingChannel = false;

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

  willDestroy() {
    super.willDestroy(...arguments);
    this.embeddableChat.activeChannel = null;
  }

  <template>
    <div
      id="custom-chat-container"
      class="chat-drawer"
      {{didInsert (fn this.findChannel @chatChannelId)}}
    >
      {{#if (and this.embeddableChat.activeChannel (not this.loadingChannel))}}
        <ChatChannel @channel={{this.embeddableChat.activeChannel}} />
      {{/if}}
    </div>
  </template>
}
