import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { next } from "@ember/runloop";
import { inject as service } from "@ember/service";
import { TrackedArray, TrackedObject } from "@ember-compat/tracked-built-ins";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import DButton from "discourse/components/d-button";
import UserInfo from "discourse/components/user-info";
import bodyClass from "discourse/helpers/body-class";
import ComboBox from "select-kit/components/combo-box";
import agendaData from "../lib/agenda-data";
import agendaModal from "./modals/agenda-modal";
import StreamSurvey from "./stream-survey";

export default class Streamer extends Component {
  @service messageBus;
  @service conference;
  @service currentUser;
  @service chatChannelsManager;
  @service appEvents;
  @service siteSettings;
  @service site;
  @service embeddableChat;
  @service modal;
  @service router;

  @tracked muxId;
  @tracked stream = 1;
  @tracked currentTitle = "Conference Starting Soon";
  @tracked conferenceStream = new TrackedObject(this.args.conferenceStream);
  @tracked
  conferenceStages = new TrackedArray(
    this.args.conferenceStream?.conference_stages
  );
  @tracked speaker;
  @tracked isLoading = true;

  @tracked selectedStage;

  chatChannelIds = this.siteSettings.conference_chat_channel_ids
    .split("|")
    .map(Number);

  stageChannelsLink = this.siteSettings.stage_channel_link
    .split("|")
    .map((item) => {
      const [stage, channel_id] = item.split(":").map(Number);
      return { stage, channel_id };
    });

  constructor() {
    super(...arguments);
    this.selectedStage = this.conferenceStages[0];

    if (!this.currentUser) {
      return;
    }

    if (!this.conference.hasConferenceStarted) {
      return;
    }

    if (localStorage.getItem("conference-user-not-signed-in")) {
      return;
    }

    if (!this.site.isMobileDevice) {
      this.initChat();
    }

    this.appEvents.on("surveySubmitted", (data) => {
      this.selectedStage.live_stage_session.survey = data;
    });

    this.messageBus.subscribe("/update_stream", this.onUpdateStream.bind(this));
    this.messageBus.subscribe("/new_survey", this.receivedSurvey.bind(this));
    this.isLoading = false;
  }

  get posterUrl() {
    return `https://image.mux.com/${this.liveSession?.external_id}/thumbnail.jpg`;
  }

  get liveSession() {
    return this.selectedStage?.live_stage_session;
  }

  get shouldRenderStream() {
    return !!this.currentUser && this.conference.hasConferenceStarted;
  }

  @action
  openAgenda() {
    this.modal.show(agendaModal, { model: agendaData });
  }

  @action
  openLastSurvey() {
    this.modal.show(StreamSurvey, {
      model: {
        isNewSurvey: false,
        ...this.selectedStage?.live_stage_session?.survey,
      },
    });
  }

  async initChat() {
    const channel = await this.chatChannelsManager.find(this.chatChannelIds[0]);

    if (!channel.currentUserMembership.following) {
      this.chatChannelsManager.follow(channel);
    }

    document.body.classList.remove("has-sidebar-page");
    this.embeddableChat.activeChannel = channel;
  }

  async receivedSurvey(data) {
    if (sessionStorage.getItem("disableSurveys") === "true") {
      return;
    }
    if (this.selectedStage?.live_stage_session?.id !== data.session_id) {
      return;
    }
    this.selectedStage.live_stage_session.survey = data;
    await this.modal.show(StreamSurvey, {
      model: { isNewSurvey: true, ...data },
    });
  }

  async onUpdateStream(parsedData) {
    this.conferenceStream = new TrackedObject(parsedData.conference_stream);
    this.conferenceStages = new TrackedArray(
      parsedData.conference_stream.conference_stages
    );

    this.conferenceStages.forEach((stage) => {
      if (stage.id === this.selectedStage.id) {
        this.selectedStage = stage;
      }
    });

    this.isLoading = false;
  }

  get startTime() {
    return moment
      .utc(this.selectedStage?.live_stage_session.start_time)
      .tz(moment.tz.guess())
      .format("h:mm A");
  }

  get endTime() {
    return moment
      .utc(this.selectedStage?.live_stage_session.end_time)
      .tz(moment.tz.guess())
      .format("h:mm A");
  }

  @action
  async changeStage(streamId) {
    const selectedStage = this.conferenceStages.find((stage) => {
      return stage.id === streamId;
    });

    this.selectedStage = selectedStage;

    const channelId = this.stageChannelsLink.find((link) => {
      return link.stage === selectedStage.id;
    })?.channel_id;

    if (channelId) {
      const channel = await this.chatChannelsManager.find(channelId);

      this.embeddableChat.activeChannel = null;

      if (!channel.currentUserMembership.following) {
        this.chatChannelsManager.follow(channel);
      }

      next(async () => {
        this.embeddableChat.activeChannel = channel;
      });
    }

    this.appEvents.trigger("livestream:changed", { selectedStage });
  }

  get stageSpeakers() {
    return this.liveSession?.speakers || [];
  }

  <template>
    {{bodyClass
      "conference-page conference-started custom-chat-enabled confirmed-event-assistance"
    }}
    {{#if this.shouldRenderStream}}
      <ConditionalLoadingSpinner @condition={{this.isLoading}}>
        <div class="row" id="stream-header">
          <h2 class="livestream-title">
            {{#if this.selectedStage}}
              {{this.selectedStage.live_stage_session.title}}
            {{else}}
              {{this.currentTitle}}
            {{/if}}
          </h2>

          <div class="links">
            <div class="stages">
              <ComboBox
                @content={{this.conferenceStages}}
                @id="stages"
                @value={{this.selectedStage.id}}
                @onChange={{this.changeStage}}
                class="relative-time-intervals"
              />
              <span class="time-badge">{{this.startTime}}
                -
                {{this.endTime}}</span>
            </div>

            <div class="pages">
              <DButton @action={{this.openAgenda}}>
                Agenda
              </DButton>
              <DButton @action={{this.openLastSurvey}}>Survey
              </DButton>
            </div>
          </div>
        </div>

        {{#if this.liveSession}}
          <mux-player
            autoplay="true"
            playback-id={{this.liveSession.external_id}}
            metadata-video-title="Placeholder (optional)"
            metadata-viewer-user-id={{this.liveSession.hash}}
            poster={{this.posterUrl}}
            accent-color="#FF0000"
          ></mux-player>
        {{else}}
          <iframe
            title="loading-video"
            src="https://streamyard.com/watch/P5Zf7AhannEX?embed=true"
            frameborder="0"
            allowfullscreen
          ></iframe>
        {{/if}}

        {{#if this.selectedStage}}
          <div class="information">

            <div class="speakers">
              {{#each this.stageSpeakers as |speaker|}}
                <UserInfo
                  @user={{speaker}}
                  @includeAvatar={{true}}
                  @skipName={{true}}
                  @showStatus={{false}}
                  @showStatusTooltip={{true}}
                />
              {{/each}}
            </div>
          </div>
        {{/if}}

      </ConditionalLoadingSpinner>
    {{/if}}
  </template>
}
