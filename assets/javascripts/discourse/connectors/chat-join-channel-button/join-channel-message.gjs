import i18n from "discourse-common/helpers/i18n";

const JoinChannelMessage = <template>
  <h2>
    {{i18n "discourse_livestream.chat.join_channel_header"}}
  </h2>
  <p>
    {{i18n "discourse_livestream.chat.join_channel_message"}}
  </p>
</template>;

export default JoinChannelMessage;
