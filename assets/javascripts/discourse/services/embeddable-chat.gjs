import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import Chat from "discourse/plugins/chat/discourse/services/chat";

export const LIVESTREAM_TAG_NAME = "livestream";

export default class EmbeddableChat extends Chat {
  @service siteSettings;
  @service site;
  @service router;
  @service currentUser;

  @tracked isMobileChatVisible = false;

  canRenderChatChannel(topicController, mobileViewAllowed = false) {
    this.topicController = topicController;
    if (
      this.site.mobileView === mobileViewAllowed &&
      this.siteSettings.chat_enabled &&
      this.currentUser &&
      this.userCanChat
    ) {
      const allowedPaths =
        this.siteSettings.embeddable_chat_allowed_paths.split("|");
      const withinPathsAllowed = allowedPaths.some(
        (path) =>
          this.router.currentURL.includes(path) ||
          this.router.currentURL.startsWith(path)
      );

      if (withinPathsAllowed && this.topicController?.model?.chat_channel_id) {
        return true;
      }
    }

    return false;
  }

  @action
  toggleChatVisibility() {
    this.isMobileChatVisible = !this.isMobileChatVisible;
  }

  topicHasLivestreamTag(topic) {
    return topic?.tags?.some?.((tag) => tag === LIVESTREAM_TAG_NAME) || false;
  }

  get isMobileModal() {
    return (
      this.siteSettings.enable_modal_chat_on_mobile && this.site.mobileView
    );
  }

  get chatChannelId() {
    return this.topicController?.model?.chat_channel_id;
  }
}
