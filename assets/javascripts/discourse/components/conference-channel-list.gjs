import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { later, next } from "@ember/runloop";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";
import i18n from "discourse-common/helpers/i18n";
import eq from "truth-helpers/helpers/eq";
import ChannelIcon from "discourse/plugins/chat/discourse/components/channel-icon";
import ChannelName from "discourse/plugins/chat/discourse/components/channel-name";
import ChatChannelMetadata from "discourse/plugins/chat/discourse/components/chat-channel-metadata";

export default class ConferenceChannelsList extends Component {
  @service conference;
  @service embeddableChat;
  @service chatChannelsManager;
  @service appEvents;
  @service siteSettings;
  @tracked lastKnownScrollPosition;

  channelsDividerIndex = this.siteSettings?.conf_channels_divider_index || 5;

  @action
  async selectChannel(channel) {
    this.embeddableChat.activeChannel = null;

    if (!channel.currentUserMembership.following) {
      this.chatChannelsManager.follow(channel);
    }
    this.lastKnownScrollPosition = window.scrollY;

    next(async () => {
      this.embeddableChat.activeChannel = channel;
      this.afterChannelUpdate();

      later(() => {
        window.scrollTo(0, this.lastKnownScrollPosition);
      }, 800);
    });
  }

  afterChannelUpdate() {
    next(() => {
      this.args.afterChannelUpdate();
    });
  }

  get sortedChannelsById() {
    return this.conference.chatChannels.sort((a, b) => {
      return a.id - b.id;
    });
  }

  <template>
    <div
      role="region"
      aria-label={{i18n "chat.aria_roles.channels_list"}}
      class="conference-channels-list"
      id="conference-channels-list"
    >
      {{#each this.sortedChannelsById as |channel index|}}

        {{#if (eq index 0)}}
          <div class="channel-divider"><span>ISC</span></div>
        {{/if}}

        {{#if (eq index this.channelsDividerIndex)}}
          <div class="channel-divider"><span>product-2</span></div>
        {{/if}}
        <DButton
          @action={{fn this.selectChannel channel}}
          class={{concatClass
            "chat-channel-row can-leave"
            (if channel.focused "focused")
            (if channel.currentUserMembership.muted "muted")
            (if (eq this.embeddableChat.activeChannel.id channel.id) "active")
          }}
          tabindex="0"
          data-chat-channel-id={{channel.id}}
        >
          <div
            class={{concatClass
              "chat-channel-row__content"
              (if channel.isCategoryChannel "is-category" "is-dm")
            }}
          >
            <ChannelIcon @channel={{channel}} />
            <div class="chat-channel-row__info">
              <ChannelName @channel={{channel}} />
              <ChatChannelMetadata
                @channel={{channel}}
                @unreadIndicator={{true}}
              />
            </div>

          </div>

        </DButton>

      {{/each}}
    </div>
  </template>
}
