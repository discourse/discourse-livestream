import Component from "@glimmer/component";
import { service } from "@ember/service";
import MobileLivestreamChatIcon from "./mobile-livestream-chat-icon";

export default class ResponsiveLivestreamChatIcon extends Component {
  @service capabilities;

  get shouldShow() {
    return !this.capabilities.viewport.lg;
  }

  <template>
    {{#if this.shouldShow}}
      <MobileLivestreamChatIcon />
    {{/if}}
  </template>
}
