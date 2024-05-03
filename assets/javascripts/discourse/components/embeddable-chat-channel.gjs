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
  @controller("topic") topicController;

  @tracked showConferenceChannelsList = false;
  @tracked topicModel = null;
  @tracked topicChannelId = null;
  @tracked isChatCollapsed = false;

  constructor() {
    super(...arguments);
    if (!this.siteSettings.enable_livestream_chat) {
      return;
    }
    this.chatStateManager.prefersDrawer(); // This will avoid opening threads in full page.

    this.appEvents.on("page:changed", this, this.initializeChat);
    window.addEventListener("resize", this.handleResize);
  }

  initializeChat() {
    const sidebar = document.querySelector(".drop-down-mode.d-header-wrap");

    this.topicModel = this.topicController?.model;
    this.topicChannelId = this.topicModel?.chat_channel_id;

    if (this.currentUser && this.topicChannelId) {
      this.chatChannelsManager.find(this.topicChannelId).then((channel) => {
        this.embeddableChat.activeChannel = channel;
        return (this.activeChannel = channel);
      });
    }

    later(() => {
      if (!this.shouldRender) {
        this.embeddableChat.activeChannel = null;
        const parentElement = document.querySelector(".discourse-root");
        parentElement.prepend(sidebar);

        document.body.classList.add("has-sidebar-page");
        document.body.classList.add("docked");

        return;
      }

      const parentElement = document.querySelector("#main");
      parentElement.prepend(sidebar);

      if (!this.topicChannelId) {
        return;
      }
      this.chatChannelsManager.find(this.topicChannelId).then((channel) => {
        this.embeddableChat.activeChannel = channel;
        return channel;
      });
    }, 100);
  }

  #isUrlAllowedForChat(url) {
    const allowedPaths =
      this.siteSettings.embeddable_chat_allowed_paths.split("|");
    return allowedPaths.some(
      (path) => url.includes(path) || url.startsWith(path)
    );
  }

  @action
  toggleChatCollapse() {
    this.isChatCollapsed = !this.isChatCollapsed;
    document.body.classList.toggle("remove-scroll-x");
    document
      .querySelector(".embeddable-chat-channel")
      .classList.toggle("chat-drawer-collapsed");

    later(() => {
      if (this.isChatCollapsed) {
        document.querySelector("#custom-chat-container").classList.add("hide");
      } else {
        document
          .querySelector("#custom-chat-container")
          .classList.remove("hide");
      }
      next(this.handleResize);
    }, 50);
  }

  get shouldRender() {
    if (
      !this.currentUser ||
      !this.siteSettings.enable_livestream_chat ||
      !this.embeddableChat.activeChannel ||
      !this.#isUrlAllowedForChat(this.router.currentURL) ||
      (this.router.currentURL.includes("/conference") &&
        !this.conference.hasConferenceStarted)
    ) {
      return false;
    }

    return !!this.embeddableChat.activeChannel;
  }

  get isConferencePage() {
    return Boolean(!this.topicModel);
  }

  @action
  toggleConferenceChannelsList() {
    this.showConferenceChannelsList = !this.showConferenceChannelsList;
    if (this.showConferenceChannelsList) {
      document.addEventListener("click", this.closeListOnOutsideClick, true);
    } else {
      document.removeEventListener("click", this.closeListOnOutsideClick, true);
    }
    next(this.handleResize);
  }

  @action
  closeListOnOutsideClick(event) {
    const conferenceChannelList = document.querySelector(
      ".conference-channels-list"
    );
    if (
      conferenceChannelList &&
      !conferenceChannelList.contains(event.target)
    ) {
      this.toggleConferenceChannelsList();
    }
  }

  @action
  handleResize() {
    document.body.classList.remove("has-sidebar-page");
    document.body.classList.remove("docked");

    const chatDrawerElement = document.querySelector("#custom-chat-container");

    if (!chatDrawerElement) {
      return;
    }

    let headerHeight = document.querySelector("header.d-header").offsetHeight;
    let offset = headerHeight + 5;

    const height = window.innerHeight - offset;

    chatDrawerElement.style.setProperty(
      "max-height",
      `${height}px`,
      "important"
    );
    chatDrawerElement.style.setProperty("height", `${height}px`, "important");
  }

  willDestroy() {
    super.willDestroy();
    window.removeEventListener("resize", this.handleResize);
  }

  <template>
    {{#if this.shouldRender}}
      {{#if this.isConferencePage}}

        <DButton
          @icon={{if
            this.isChatCollapsed
            "angle-double-left"
            "angle-double-right"
          }}
          @action={{this.toggleChatCollapse}}
          class="chat-collapsible-toggle-button"
        />
        <div class="chat-drawer-header" id="conference-chat-switcher">
          {{#if this.showConferenceChannelsList}}
            <DButton
              @icon="bars"
              @action={{this.toggleConferenceChannelsList}}
              @translatedLabel={{this.embeddableChat.activeChannel.title}}
              class="chat-drawer-header-button"
            />
            <ConferenceChannelList
              @afterChannelUpdate={{this.toggleConferenceChannelsList}}
            />
          {{else}}
            <DButton
              @icon="bars"
              @action={{this.toggleConferenceChannelsList}}
              @translatedLabel={{this.embeddableChat.activeChannel.title}}
              class="chat-drawer-header-button"
            />
          {{/if}}
        </div>
      {{/if}}
      <div
        id="custom-chat-container"
        class="chat-drawer chat-drawer-active"
        {{didInsert this.handleResize}}
        {{didUpdate this.handleResize}}
      >
        <ChatChannel @channel={{this.embeddableChat.activeChannel}} />
      </div>
    {{/if}}
  </template>
}
