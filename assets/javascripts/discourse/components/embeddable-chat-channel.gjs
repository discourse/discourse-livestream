import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { inject as controller } from "@ember/controller";
import { array } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
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
  @tracked activeChannel;

  updateChannel = modifier(async () => {
    if (this.args.chatChannelId === this.activeChannel?.id) {
      return;
    }

    this.activeChannel = await this.chatChannelsManager.find(
      this.args.chatChannelId
    );
  });

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
  closeChat() {
    this.embeddableChat.toggleChatVisibility();
  }

  <template>
    <div
      id="custom-chat-container"
      {{toggleClass this.embeddableChat.isMobileChatVisible "mobile"}}
      class={{unless this.embeddableChat.isMobileModal "no-modal-mobile"}}
      {{this.updateChannel}}
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
        {{#if this.activeChannel}}
          {{#each (array this.activeChannel) as |channel|}}
            <ChatChannel @channel={{channel}} />
          {{/each}}
        {{/if}}
      </div>
    </div>
  </template>
}
