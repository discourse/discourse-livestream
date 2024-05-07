import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import EmbedableChatChannel from "../../components/embeddable-chat-channel";
import DButton from "discourse/components/d-button";
import { tracked } from "@glimmer/tracking";
import { and } from "truth-helpers";
import { action } from "@ember/object";

export default class MobileEmbedableChatChannel extends Component {
  @service site;

  @tracked showChat = true;

  @action
  toggleChat() {
    this.showChat = !this.showChat;
  }

  <template>
    {{#if this.site.mobileView}}
      <DButton
        @label={{"discourse_livestream.chat"}}
        @action={{this.toggleChat}}
        @icon={{if this.showChat "caret-down" "caret-up"}}
        id="in-topic-livestream-chat-toggle"
      />
      {{#if this.showChat}}
        <EmbedableChatChannel @inTopic={{true}} />
      {{/if}}
    {{/if}}
  </template>
}
