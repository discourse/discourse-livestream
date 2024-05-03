import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { Input } from "@ember/component";
import { fn } from "@ember/helper";
import { TextArea } from "@ember/legacy-built-in-components";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class StreamSurvey extends Component {
  @service appEvents;

  @tracked userScore = this.args.model.survey_response?.score || null;
  @tracked comment = this.args.model.survey_response?.comment || "";
  @tracked disableSurveys = sessionStorage.getItem("disableSurveys") === "true";
  @tracked isPreviousSurvey;
  isNewSurvey = this.args.model.isNewSurvey;
  commentCharactersLimit = 1000;
  sessionId = this.args.model.session_id;
  surveyId = this.args.model.survey_id || this.args.model.id;
  title = this.args.model.title;

  constructor() {
    super(...arguments);
    this.isPreviousSurvey =
      !this.args.model.isNewSurvey &&
      (this.userScore !== null || this.comment.length !== 0);
  }

  get starValues() {
    return [5, 4, 3, 2, 1];
  }

  get remainingCharacters() {
    return this.commentCharactersLimit - this.comment.length;
  }

  @action
  toggleSurveys() {
    this.disableSurveys = !this.disableSurveys;
  }

  @action
  updateComment(event) {
    this.comment = event.target.value.substring(0, this.commentCharactersLimit);
  }

  @action
  submitScore() {
    sessionStorage.setItem("disableSurveys", this.disableSurveys);
    if (this.userScore === null && this.comment.length === 0) {
      this.args.closeModal();
      return;
    }
    if (
      this.isPreviousSurvey &&
      (this.userScore !== null || this.comment.length !== 0)
    ) {
      this.args.closeModal();
      return;
    }
    ajax(`conference/surveys/${this.surveyId}/submit_response`, {
      type: "POST",
      data: {
        survey_response: {
          score: this.userScore,
          comment: this.comment,
        },
      },
    })
      .then((response) => {
        this.appEvents.trigger("surveySubmitted", {
          session_id: this.sessionId,
          id: this.surveyId,
          title: this.title,
          survey_response: { ...response.conference_survey_response },
        });

        this.args.closeModal();
      })
      .catch((error) => {
        popupAjaxError(error);
      });
  }

  @action
  updateScore(score) {
    this.userScore = score;
  }

  @action
  interceptCloseModal() {
    this.args.closeModal();
  }

  isScoreSelected(currentScore, selectedScore) {
    return currentScore === selectedScore ? "checked" : "";
  }

  <template>
    <DModal
      @title="Survey"
      @closeModal={{this.interceptCloseModal}}
      class="survey-modal"
    >
      <:body>
        <div>
          <h1>{{this.title}}</h1>
          <div class="star-rating">

            <div class="star-rating">
              {{#each this.starValues as |starValue|}}
                <input
                  type="radio"
                  {{on "click" (fn this.updateScore starValue)}}
                  id="star{{starValue}}"
                  checked={{this.isScoreSelected starValue this.userScore}}
                  name="rating"
                  disabled={{this.isPreviousSurvey}}
                  value={{starValue}}
                  class="star"
                />
                <label for="star{{starValue}}">☆</label>
              {{/each}}
            </div>

          </div>
          <TextArea
            disabled={{this.isPreviousSurvey}}
            @value={{this.comment}}
            {{on "input" this.updateComment}}
            @placeholder="Share your thoughts (Optional)"
            @class="form-control"
            @rows="3"
          />

          <span class="remaining-characters">
            {{this.remainingCharacters}}
            characters remaining
          </span>

        </div>
      </:body>
      <:footer>
        <DButton
          @translatedLabel="Submit"
          @action={{this.submitScore}}
          @class="btn-primary"
        />
        <label for="disable-survey" class="disable-surveys">
          <Input
            @checked={{this.disableSurveys}}
            @type="checkbox"
            id="disable-survey"
            name="disable-survey"
            {{on "click" this.toggleSurveys}}
          />
          Disable Survey Dialogs</label>
      </:footer>
    </DModal>
  </template>
}
