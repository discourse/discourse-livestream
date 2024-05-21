import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { inject as controller } from "@ember/controller";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { later, next } from "@ember/runloop";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import ChatChannel from "discourse/plugins/chat/discourse/components/chat-channel";
import ConferenceChannelList from "./conference-channel-list";

export default class EmbedableChatChannel extends Component {
  @service chatChannelsManager;
  @service currentUser;
  @service embeddableChat;
  @service appEvents;
  @service siteSettings;
  @service conference;
  @service chatStateManager;
  @service router;
  @service sidebarState;
  @controller("topic") topicController;

  @tracked showConferenceChannelsList = false;
  @tracked topicModel = null;
  @tracked topicChannelId = null;
  @tracked isChatCollapsed = false;
  @tracked loadingChannel = false;

  constructor() {
    super(...arguments);
    this.appEvents.on("page:changed", this, this.initializeChat);
    // this.chatStateManager.prefersDrawer(); // This will avoid opening threads in full page.
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

  setCustomChatStyles(site) {
    document
      .querySelector(".topic-navigation")
      .style.setProperty("display", "none");

    if (!site.mobileView) {
      document.body.classList.add("custom-chat-enabled");
    }

    document
      .querySelector(".sidebar-sections")
      .style.setProperty("display", "none");

    document
      .querySelector(".sidebar-footer-wrapper")
      .style.setProperty("display", "none");
  }

  resetCustomChatStyles() {
    document
      .querySelector(".topic-navigation")
      .style.setProperty("display", "block");

    document.body.classList.remove("custom-chat-enabled");

    document
      .querySelector(".sidebar-sections")
      .style.setProperty("display", "block");

    document
      .querySelector(".sidebar-footer-wrapper")
      .style.setProperty("display", "block");
  }

  willDestroy() {
    super.willDestroy();
    window.removeEventListener("resize", this.handleResize);
  }

  <template>
    {{#if this.shouldRender}}
      <div
        id="custom-chat-container"
        class="chat-drawer"
        {{! we have to override the \`!important\` chat styles  }}
        style="height: 100% !important;"
      >
        <ChatChannel @channel={{this.embeddableChat.activeChannel}} />
      </div>
    {{/if}}
  </template>
}
