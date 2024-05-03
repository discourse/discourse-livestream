import { next } from "@ember/runloop";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class ConferenceAgendaRoute extends DiscourseRoute {
  model() {
    return ajax("agenda");
  }

  async activate() {
    document.body.classList.remove("docked");
    next(() => {
      const bannerSelector = document.querySelector(
        ".discovery-list-controls-above-outlet .card-component__content"
      );

      if (!bannerSelector) {
        return;
      }
      bannerSelector.style.background = "var(--secondary)";
      bannerSelector.style.color = "var(--primary)";
    });
  }
}
