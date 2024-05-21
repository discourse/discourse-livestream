import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";

export default class GoingButton extends Component {
  @service store;
  @service appEvents;

  @action
  acceptInvitation() {
    const topicPost = parseInt(
      document.getElementById("post_1").dataset.postId
    );
    this.store
      .createRecord("discourse-post-event-invitee")
      .save({ post_id: topicPost, status: "going" });
    this.appEvents.trigger("calendar:create-invitee-status", {
      status: "going",
      postId: topicPost,
    });
  }

  <template>
    <DButton
      @icon="check"
      class="btn-primary"
      @label="discourse_livestream.chat.going"
      @action={{this.acceptInvitation}}
    />
  </template>
}
