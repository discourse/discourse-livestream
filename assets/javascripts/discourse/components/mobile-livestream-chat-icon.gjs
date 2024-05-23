import Component from "@glimmer/component";
import DButton from "discourse/components/d-button";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import MobileEmbeddableChatModal from "./modal/mobile-embeddable-chat-modal";

export default class MobileLivestreamChatIcon extends Component {
  @service modal;

  @action
  openLivestreamChat() {
    this.modal.show(MobileEmbeddableChatModal);
  }

  <template>
    <li class="header-dropdown-toggle livestream-header-icon">
      <DButton
        @icon="d-chat"
        class="icon btn-flat"
        tabindex="0"
        @action={{this.openLivestreamChat}}
      />
    </li>
  </template>
}
