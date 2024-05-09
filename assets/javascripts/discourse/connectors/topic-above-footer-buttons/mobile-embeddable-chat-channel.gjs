import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import EmbedableChatChannel from "../../components/embeddable-chat-channel";

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
        @label="discourse_livestream.chat"
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
