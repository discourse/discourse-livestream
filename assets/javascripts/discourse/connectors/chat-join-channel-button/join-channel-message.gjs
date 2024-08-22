import i18n from "discourse-common/helpers/i18n";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";
import { inject as controller } from "@ember/controller";
import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import LIVESTREAM_TAG_NAME from "../../services/embeddable-chat";

export default class JoinChannelMessage extends Component {
  @controller("topic") topicController;
  @service embeddableChat;

  get shouldRenderJoinText() {
    const topic = this.topicController?.model;
    return (
      topic?.chat_channel_id && this.embeddableChat.topicHasLivestreamTag(topic)
    );
  }

  <template>
    {{#if this.shouldRenderJoinText}}
      <h2>
        {{i18n "discourse_livestream.chat.join_channel_header"}}
      </h2>
      <p>
        {{i18n "discourse_livestream.chat.join_channel_message"}}
      </p>
    {{else}}
      <DButton
        @action={{@outletArgs.onJoinChannel}}
        @translatedLabel={{@outletArgs.label}}
        @translatedTitle={{@outletArgs.options.joinTitle}}
        @icon={{@outletArgs.options.joinIcon}}
        @disabled={{@outletArgs.isLoading}}
        class={{concatClass
          "toggle-channel-membership-button -join"
          @outletArgs.options.joinClass
        }}
      />
    {{/if}}
  </template>
}
