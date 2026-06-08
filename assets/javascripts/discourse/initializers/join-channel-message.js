import { withPluginApi } from "discourse/lib/plugin-api";
import JoinChannelMessage from "../components/join-channel-message";

export default {
  name: "discourse-livestream-join-channel-message",
  initialize() {
    withPluginApi((api) => {
      const siteSettings = api.container.lookup("service:site-settings");

      // If the core discourse-calendar livestream is enabled, this
      // plugin should be a noop.
      if (siteSettings.livestream_enabled) {
        return;
      }

      api.renderInOutlet("chat-join-channel-button", JoinChannelMessage);
    });
  },
};
