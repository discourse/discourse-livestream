import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { inject as service } from "@ember/service";

export default class ConferenceIndexController extends Controller {
  @service currentUser;
  @service siteSettings;
  @service conference;
  @tracked showStreamer = false;

  get shouldShowRegistrationPage() {
    return (
      !this.userBelongsToRegistrationGroup ||
      !this.conference.hasConferenceStarted
    );
  }

  get userBelongsToRegistrationGroup() {
    if (!this.currentUser) {
      return false;
    }

    if (this.currentUser.admin) {
      return true;
    }

    return this.model?.conference_stream?.is_current_user_registered;
  }
}
