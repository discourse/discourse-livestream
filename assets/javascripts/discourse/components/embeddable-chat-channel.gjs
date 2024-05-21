import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { inject as controller } from "@ember/controller";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import ChatChannel from "discourse/plugins/chat/discourse/components/chat-channel";

export default class EmbedableChatChannel extends Component {
  @service chatChannelsManager;
  @service currentUser;
  @service embeddableChat;
  @service appEvents;
  @service siteSettings;
  @service router;
  @controller("topic") topicController;

  @tracked showConferenceChannelsList = false;
  @tracked topicModel = null;
  @tracked topicChannelId = null;
  @tracked isChatCollapsed = false;
  @tracked loadingChannel = false;

  constructor() {
    super(...arguments);
    this.appEvents.on("page:changed", this, this.initializeChat);
  }

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

  initializeChat() {
    this.topicModel = this.topicController?.model;
    this.topicChannelId = this.topicModel?.chat_channel_id;

    if (this.currentUser && this.topicChannelId) {
      return this.findChannel(this.topicChannelId);
    }

    if (!this.shouldRender) {
      this.embeddableChat.activeChannel = null;
    }
  }

  #isUrlAllowedForChat(url) {
    const allowedPaths =
      this.siteSettings.embeddable_chat_allowed_paths.split("|");
    return allowedPaths.some(
      (path) => url.includes(path) || url.startsWith(path)
    );
  }

  get shouldRender() {
    if (
      this.loadingChannel ||
      !this.currentUser ||
      !this.embeddableChat.activeChannel ||
      !this.#isUrlAllowedForChat(this.router.currentURL)
    ) {
      return false;
    }

    return !!this.embeddableChat.activeChannel;
  }

  <template>
    {{#if this.shouldRender}}
      <div
        id="custom-chat-container"
        class="chat-drawer"
        {{! We need to override core's '!important' chat-drawer height}}
        style="height: 100% !important"
      >
        <ChatChannel @channel={{this.embeddableChat.activeChannel}} />
      </div>
    {{/if}}
  </template>
}
