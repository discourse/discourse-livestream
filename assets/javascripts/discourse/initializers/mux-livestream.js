import loadScript from "discourse/lib/load-script";
import { withPluginApi } from "discourse/lib/plugin-api";
const MUX_PLAYER_SCRIPT_URL =
  "/plugins/discourse-livestream/javascripts/mux-player.min.js";

function initializeMuxLivestream() {
  loadScript(MUX_PLAYER_SCRIPT_URL);
}

export default {
  name: "discourse-mux-livestream",

  initialize(container) {
    const siteSettings = container.lookup("service:site-settings");

    if (siteSettings.enable_discourse_livestream) {
      withPluginApi("0.8.31", initializeMuxLivestream);
    }
  },
};
