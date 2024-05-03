import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import bodyClass from "discourse/helpers/body-class";
import concatClass from "discourse/helpers/concat-class";
import ComboBox from "select-kit/components/combo-box";
import eq from "truth-helpers/helpers/eq";

export default class ConferenceAgenda extends Component {
  @service conference;
  @tracked selectedRegion = this.formattedAgenda[0] ?? null;
  @tracked selectedDay = this.selectedRegion?.days[0] ?? null;
  @tracked selectedStage = this.selectedDay?.stages[0] ?? null;
  @tracked currentDate = this.selectedStage?.details[0]?.startTime ?? null;
  @tracked expandedStageDescriptions = new Set();
  descriptionCutoffLength = 105;

  constructor() {
    super(...arguments);
    this.conference.handleColorSchema();
  }

  @action
  excerpt(stage) {
    const { description } = stage;
    const cutoff = this.descriptionCutoffLength;

    if (
      this.expandedStageDescriptions.has(stage.topic) ||
      description.length <= cutoff
    ) {
      return description;
    }

    return `${description.substring(0, cutoff)}...`;
  }

  @action
  shouldRenderDescription(description) {
    return (
      description.length && description.length > this.descriptionCutoffLength
    );
  }

  @action
  toggleDescription(stageIdentifier) {
    if (this.expandedStageDescriptions.has(stageIdentifier)) {
      this.expandedStageDescriptions.delete(stageIdentifier);
    } else {
      this.expandedStageDescriptions.add(stageIdentifier);
    }
    this.expandedStageDescriptions = new Set(this.expandedStageDescriptions);
  }

  isDescriptionExpanded(expandedStageDescriptions, topic) {
    return expandedStageDescriptions.has(topic);
  }

  get currentDateFormatted() {
    this.currentDate = this.selectedStage?.details[0]?.startTime;
    return moment(this.currentDate)?.format("MMMM, Do");
  }

  get regions() {
    return this.formattedAgenda.map((region) => region.region);
  }

  get formattedAgenda() {
    const agenda = this.args.agenda;
    if (!agenda) {
      return [];
    }

    return Object.entries(agenda).map(([region, days]) => {
      return {
        name: region,
        id: region,
        days: Object.entries(days).map(([day, stages]) => {
          return {
            day,
            stages: Object.entries(stages).map(([stage, details]) => {
              return { stage, details };
            }),
          };
        }),
      };
    });
  }

  @action
  setDay(day) {
    this.selectedDay = day;
    this.selectedStage = day.stages[0];
  }

  @action
  setStage(stage) {
    this.selectedStage = stage;
  }

  @action
  formatTime(time) {
    return moment.utc(time).tz(moment.tz.guess()).format("HH:mm z");
  }

  @action
  calculateDuration(stage) {
    const startTime = moment(stage.startTime);
    const endTime = moment(stage.endTime);
    const duration = moment.duration(endTime.diff(startTime));
    return duration.asMinutes();
  }

  @action
  onChangeRegion(value) {
    this.selectedRegion = this.formattedAgenda.find(
      (region) => region.id === value
    );
    this.selectedDay = this.selectedRegion.days[0];
    this.selectedStage = this.selectedDay.stages[0];
  }
  <template>
    {{bodyClass "conference-page agenda"}}

    <div class="info-box">
      <img class="banner" src={{this.conference.banner}} alt="banner" />

      <div class="container">
        <div class="row">
          <h1 class="title">Agenda</h1>
        </div>

        <div class="row">
          <div class="control-group">
            <div class="button-group">

              {{#each this.selectedRegion.days as |day|}}
                <DButton
                  @action={{fn this.setDay day}}
                  class={{concatClass
                    "btn button"
                    (if (eq this.selectedDay day) "btn-active")
                  }}
                >{{day.day}}</DButton>
              {{/each}}
            </div>

          </div>
        </div>

        <div class="row">
          <div class="control-group">
            <div class="button-group">
              {{#each this.selectedDay.stages as |stage|}}
                <DButton
                  @action={{fn this.setStage stage}}
                  class={{concatClass
                    "btn button large"
                    (if (eq this.selectedStage stage) "btn-active")
                  }}
                >{{stage.stage}}</DButton>
              {{/each}}
            </div>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="schedule">
          <div class="region-info">
            <h2 class="formatted-date">{{this.currentDateFormatted}}</h2>
            <ComboBox
              @content={{this.formattedAgenda}}
              @id="region"
              @value={{this.selectedRegion.id}}
              @onChange={{this.onChangeRegion}}
              class="relative-time-intervals"
            />
          </div>
          {{#each this.selectedStage.details as |stage|}}
            <div class="time-slot">
              <div class="time">
                <p class="card-text">{{this.formatTime stage.startTime}}</p>
              </div>
              <div class="event">
                <div class="stage-info">
                  <h2>{{stage.topic}}</h2>
                  {{#if (this.shouldRenderDescription stage.description)}}
                    <div class="description">
                      {{this.excerpt stage}}
                      {{#if
                        (this.isDescriptionExpanded
                          this.expandedStageDescriptions stage.topic
                        )
                      }}
                        <DButton
                          @icon="chevron-up"
                          @action={{fn this.toggleDescription stage.topic}}
                        />
                      {{else}}
                        <DButton
                          @icon="chevron-down"
                          @action={{fn this.toggleDescription stage.topic}}
                        />
                      {{/if}}
                    </div>
                  {{/if}}

                  {{#each stage.speakers as |speaker|}}
                    <div class="speaker">{{speaker.speaker}}
                      -
                      {{speaker.title}}</div>
                  {{/each}}
                </div>
                <span class="duration"><h2
                    class="card-text"
                  >{{this.calculateDuration stage}}</h2>
                  minutes</span>
              </div>
            </div>
          {{/each}}
        </div>
      </div>
    </div>
  </template>
}
