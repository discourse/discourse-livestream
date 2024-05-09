import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { later, next } from "@ember/runloop";
import Service, { inject as service } from "@ember/service";
import { getURLWithCDN } from "discourse-common/lib/get-url";

const COLOR_SCHEME_OVERRIDE_KEY = "color_scheme_override";

export default class ConferenceService extends Service {
  @service router;
  @service siteSettings;
  @service chatChannelsManager;
  @service currentUser;
  @tracked chatChannels = [];
  @tracked isDarkMode = this.OSMode;
  chatChannelIds = this.siteSettings.conference_chat_channel_ids
    .split("|")
    .map(Number);
  constructor() {
    super(...arguments);
    if (!this.currentUser) {
      return;
    }
    this.chatChannelIds.forEach((chatChannelId) => {
      this.chatChannelsManager.find(chatChannelId).then((channel) => {
        this.chatChannels.pushObject(channel);
      });
    });
  }

  get hasConferenceStarted() {
    const conferenceStartMoment = moment.tz(
      this.siteSettings.conference_start_time,
      this.siteSettings.conference_start_timezone
    );
    const nowInCentralTime = moment();

    const allowedGroups = this.siteSettings.conference_livestream_enabled_groups
      .split("|")
      .filter((group) => group.trim().length > 0);

    const didConferenceStart = nowInCentralTime.isSameOrAfter(
      conferenceStartMoment
    );

    if (allowedGroups.length > 0 && !this.userBelongsToGroups(allowedGroups)) {
      return didConferenceStart;
    } else if (
      allowedGroups.length > 0 &&
      this.userBelongsToGroups(allowedGroups)
    ) {
      return true; //bypass date check if user is in allowed group
    }

    return didConferenceStart;
  }

  userBelongsToGroups(allowedGroups) {
    if (!this.currentUser) {
      return false;
    }
    const allowedGroupStrings = allowedGroups.map(String);

    return this.currentUser.groups.some((group) =>
      allowedGroupStrings.includes(String(group.id))
    );
  }

  @action
  checkColorSchema() {
    next(() => {
      const scheme =
        this.keyValueStore.getItem(COLOR_SCHEME_OVERRIDE_KEY) || this.OSMode;

      this.isDarkMode = scheme === "dark";
    });
  }

  get OSMode() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
  }

  handleColorSchema() {
    later(() => {
      this.handleDarkMode();
    }, 500);
  }

  handleDarkMode() {
    this.checkColorSchema();
    const toggler = document.querySelector(".color-scheme-toggler");
    if (toggler) {
      toggler.addEventListener("click", this.checkColorSchema);
    }
  }
  get isConferenceGroupShowPage() {
    return this.router.currentRoute.parent.params.name.includes(
      this.siteSettings.conference_group_name
    );
  }

  get banner() {
    if (this.isDarkMode) {
      return getURLWithCDN(
        "/plugins/discourse-livestream/images/logo-dark-sm.png"
      );
    }

    return getURLWithCDN("/plugins/discourse-livestream/images/logo-sm.png");
  }
}
