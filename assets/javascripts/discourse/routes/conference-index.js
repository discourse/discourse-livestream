import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class ConferenceIndexRoute extends DiscourseRoute {
  @service conference;
  @service siteSettings;
  @service currentUser;

  setupController(controller, model) {
    controller.setProperties({
      showStreamer: true,
      model,
    });
  }

  model() {
    if (!this.currentUser) {
      return null;
    }
    return ajax(
      `/conference/streams/${this.siteSettings.current_conf_stream_id}.json`
    );
  }

  async activate() {
    document.body.classList.remove("docked");
  }

  async deactivate() {
    this.controller.set("showStreamer", false);
    document.body.classList.add("has-sidebar-page");
  }
}
