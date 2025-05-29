import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { inject as controller } from "@ember/controller";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import { and, not } from "truth-helpers";
import DButton from "discourse/components/d-button";
import { bind } from "discourse/lib/decorators";
import ChatChannel from "discourse/plugins/chat/discourse/components/chat-channel";
import toggleClass from "../modifiers/toggle-class";

export default class EmbedableChatChannel extends Component {
  @service chatChannelsManager;
  @service chatApi;
  @service currentUser;
  @service embeddableChat;
  @service appEvents;
  @service site;
  @service siteSettings;
  @service chatDraftsManager;
  @service messageBus;
  @controller("topic") topicController;

  @tracked topicModel = null;
  @tracked topicChannelId = null;
  @tracked loadingChannel = false;
  @tracked activeChannel;

  constructor() {
    super(...arguments);
    this.messageBus.subscribe(
      "discourse_livestream_update_livestream_chat_status",
      this.onMessage
    );
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this.chatDraftsManager.reset();
    this.embeddableChat.activeChannel = null;
    this.messageBus.unsubscribe(
      "discourse_livestream_update_livestream_chat_status",
      this.onMessage
    );
  }

  @bind
  async onMessage(membership) {
    membership = JSON.parse(membership).user_channel_membership;
    this.activeChannel.currentUserMembership = membership;
  }

  @action
  async findChannel(channelId) {
    try {
      this.loadingChannel = true;
      this.activeChannel = await this.chatChannelsManager.find(channelId);
    } finally {
      this.loadingChannel = false;
    }
  }

  @action
  closeChat() {
    this.embeddableChat.toggleChatVisibility();
  }

  <template>
    <div
      id="custom-chat-container"
      {{toggleClass this.embeddableChat.isMobileChatVisible "mobile"}}
      class={{unless this.embeddableChat.isMobileModal "no-modal-mobile"}}
      {{didInsert (fn this.findChannel @chatChannelId)}}
    >
      {{#unless this.embeddableChat.isMobileModal}}
        <div class="c-navbar-container livestream-chat-close">

          <DButton
            @icon="xmark"
            @action={{this.closeChat}}
            @title="chat.close"
            class="btn-transparent no-text c-navbar__close-drawer-button"
          />
        </div>
      {{/unless}}
      <div class="chat-drawer">
        {{#if (and this.activeChannel (not this.loadingChannel))}}
          <ChatChannel @channel={{this.activeChannel}} />
        {{/if}}
      </div>
    </div>
  </template>
}
