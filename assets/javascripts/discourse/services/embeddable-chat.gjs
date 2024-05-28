import { inject as service } from "@ember/service";
import Chat from "discourse/plugins/chat/discourse/services/chat";

export default class EmbeddableChat extends Chat {
  @service siteSettings;
  @service site;
  @service router;
  @service currentUser;

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

  get chatChannelId() {
    return this.topicController?.model?.chat_channel_id;
  }
}
