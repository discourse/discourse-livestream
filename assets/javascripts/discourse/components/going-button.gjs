import Component from "@glimmer/component";
import { inject as controller } from "@ember/controller";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";

export default class GoingButton extends Component {
  @service store;
  @service appEvents;
  @controller("topic") topicController;

  @action
  acceptInvitation() {
    const status = "going";

    this.store
      .createRecord("discourse-post-event-invitee")
      .save({ post_id: this.topicController.currentPostId, status });
    this.appEvents.trigger("calendar:create-invitee-status", {
      status,
      postId: this.topicController.currentPostId,
    });
  }

  <template>
    <DButton
      @icon="check"
      class="going-button btn btn-default"
      @translatedLabel="Going"
      @action={{this.acceptInvitation}}
    />
  </template>
}
