import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { isBlank } from "@ember/utils";
import DButton from "discourse/components/d-button";
import DToggleSwitch from "discourse/components/d-toggle-switch";
import RadioButton from "discourse/components/radio-button";
import TextField from "discourse/components/text-field";
import bodyClass from "discourse/helpers/body-class";
import { ajax } from "discourse/lib/ajax";
import { extractError } from "discourse/lib/ajax-error";
import DiscourseURL from "discourse/lib/url";
import getURL from "discourse-common/lib/get-url";
import ComboBox from "select-kit/components/combo-box";
import countryList from "../lib/country-list";

export default class RegistrationForm extends Component {
  @service currentUser;
  @service dialog;
  @service keyValueStore;
  @service messageBus;
  @service session;
  @service siteSettings;
  @service conference;

  @tracked forceRenderComingSoon = false;
  @tracked days;
  @tracked hours;
  @tracked minutes;
  @tracked seconds;

  @tracked isLoading = false;
  @tracked selectedTitle = "developer";

  @tracked selectedConference = this.availableConferences[0];
  @tracked selectedCountry = "USA";
  @tracked companyName;
  @tracked flash;
  @tracked acceptedTos;
  @tracked introPassed = false;

  availableConferences = this.siteSettings.available_conferences.split("|");

  constructor() {
    super(...arguments);

    this.conference.handleColorSchema();

    if (!this.currentUser) {
      localStorage.setItem("conference-user-not-signed-in", true);
      document.body.classList.add("user-not-signed-in");
      return;
    }

    if (!this.conference.hasConferenceStarted) {
      this.calculateRemainingTime();
      this.startTimer();

      return;
    }
    this.isLoading = false;
  }

  @action
  onChangeCountry(country) {
    this.selectedCountry = country;
  }
  @action
  onChangeSelectedConference(id) {
    let index = this.parsedConferences.findIndex((c) => c.id === id);
    this.selectedConference = this.availableConferences[index];
  }

  @action
  onChangeTitle(title) {
    this.selectedTitle = title;
  }

  @action
  toggleTos() {
    this.acceptedTos = !this.acceptedTos;
  }

  get selectedConferenceId() {
    return this.selectedConference.split(",")[0];
  }

  get selectedConferenceStartingDate() {
    // FIXME: Workaround for https://github.com/NullVoxPopuli/ember-eslint-parser/issues/30
    // eslint-disable-next-line no-unused-vars
    const [_1, _2, _3, timePart, datePart] = this.selectedConference.split(",");
    const [startTime] = timePart.split("-");
    const [startDate] = datePart.split("-");
    const timeZone = timePart.split(" ").pop();
    const year = new Date().getFullYear();

    return moment(
      `${startDate} ${year} ${startTime} ${timeZone}`,
      "MMMM Do YYYY hA z"
    );
  }

  get titles() {
    const titles = this.siteSettings.conference_titles.split("|").map((t) => {
      let values = t.split(":");
      return { id: values[0], name: values[1] };
    });

    return [...titles, { id: "other", name: "Other" }];
  }

  get shouldRenderIntro() {
    return !this.introPassed && !this.shouldRenderComingSoon;
  }

  get shouldRenderConferenceRegistration() {
    return (
      this.introPassed &&
      !this.forceRenderComingSoon &&
      this.currentUser &&
      !this.args.isUserRegisteredToConf
    );
  }

  get shouldRenderComingSoon() {
    if (this.forceRenderComingSoon) {
      return true;
    }
    return (
      this.currentUser &&
      this.args.isUserRegisteredToConf &&
      !this.conference.hasConferenceStarted
    );
  }

  calculateRemainingTime() {
    const timeDiff = this.selectedConferenceStartingDate.diff(moment());

    const duration = moment.duration(timeDiff);

    this.days = Math.floor(duration.asDays());
    this.hours = duration.hours();
    this.minutes = duration.minutes();
    this.seconds = duration.seconds();

    if (this.conference.hasConferenceStarted) {
      DiscourseURL.redirectTo("/conference");
    }
  }

  startTimer() {
    this.timer = setInterval(() => {
      this.calculateRemainingTime();
    }, 1000);
  }

  willDestroy() {
    super.willDestroy(...arguments);
    clearInterval(this.timer);

    const toggler = document.querySelector(".color-scheme-toggler");
    if (toggler) {
      toggler.removeEventListener("click", this.checkColorSchema);
    }
  }

  @action
  async completeRegistration() {
    if (!(await this.validateRegistrationInputs())) {
      await this.dialog.alert(this.flash);
      return;
    }

    this.isLoading = true;

    await this.sendRegistration({
      data: {
        company: this.companyName,
        title: this.selectedTitle,
        selected_conference: this.selectedConferenceId,
        country: this.selectedCountry,
      },
    });

    this.calculateRemainingTime();
    this.startTimer();
    this.isLoading = false;
  }

  async validateRegistrationInputs() {
    this.flash = null;
    if (!this.acceptedTos) {
      this.flash = "You must accept the terms of service to register";
    }
    if (isBlank(this.selectedCountry)) {
      this.flash = "Selected country is not valid";
    }
    if (isBlank(this.selectedConference)) {
      this.flash = "Your selected conference is not valid";
    }
    if (isBlank(this.selectedTitle)) {
      this.flash = "Your selected title is not valid";
    }
    if (isBlank(this.companyName)) {
      this.flash = "Your company name is not valid";
    }
    return this.flash === null;
  }

  async sendRegistration(data) {
    try {
      const response = await ajax(getURL("/conference/register.json"), {
        type: "POST",
        data,
      });

      if (response.success) {
        this.forceRenderComingSoon = true;
      }
    } catch (e) {
      await this.dialog.alert(extractError(e));
      this.isLoading = false;
    }
  }

  get parsedConferences() {
    return this.availableConferences.map((confs, index) => {
      const [
        id,
        region,
        name,
        time,
        date,
        secondaryProductName,
        secondaryProductDate,
      ] = confs.split(",");
      return {
        index,
        id,
        region,
        name,
        time,
        date,
        secondaryProductName,
        secondaryProductDate,
      };
    });
  }

  @action
  passIntro() {
    if (this.currentUser) {
      this.introPassed = true;
      return;
    }
    document.querySelector(".sign-up-button").click();
  }

  <template>
    {{bodyClass
      "conference-page has-sidebar-page pending-conference-registration"
    }}
    {{#if this.shouldRenderComingSoon}}
      <div class="info-box">
        <img class="banner" src={{this.conference.banner}} alt="banner" />
        <div class="row">
          <h1>{{htmlSafe
              this.siteSettings.successful_conference_registration_thanks_message
            }}</h1>
        </div>
        <br />
        <div class="row">
          <div class="form">
            <h2>{{htmlSafe
                this.siteSettings.successful_conference_registration_come_back_label
              }}
              {{this.days}}
              Days,
              {{this.hours}}
              Hours,
              {{this.minutes}}
              Minutes, and
              {{this.seconds}}
              Seconds
            </h2>
            <p>{{htmlSafe
                this.siteSettings.successful_conference_registration_message
              }}</p>
          </div>
        </div>
      </div>
    {{/if}}

    {{#if this.shouldRenderConferenceRegistration}}
      <div class="info-box">
        <img class="banner" src={{this.conference.banner}} />
        <div class="row">
          <h1>{{htmlSafe this.siteSettings.conference_registration_title}}</h1>
          <p>{{htmlSafe
              this.siteSettings.conference_registration_description
            }}</p>
        </div>

        <div class="row form">
          <div class="input-group input-radio">
            <label for="which-conference">{{htmlSafe
                this.siteSettings.conference_registration_conf_selection_label
              }}<span class="required">*</span></label>
            {{#each this.parsedConferences as |conference|}}

              <label class="custom-radio-button">
                <RadioButton
                  @name="selected_conference"
                  @value={{conference.id}}
                  @selection={{this.selectedConferenceId}}
                  @onChange={{this.onChangeSelectedConference}}
                  class="hidden-radio"
                />
                <span class="radio-custom"></span>
                <div class="event-info">
                  <div class="event-name">{{conference.region}}</div>
                  <div class="event-details product">{{conference.name}}</div>
                  <div class="event-details">{{conference.date}}</div>
                  <div class="event-details">{{conference.time}}</div>
                </div>
                <div class="event-info secondary">
                  <div class="event-name">.</div>
                  <div
                    class="event-details product"
                  >{{conference.secondaryProductName}}</div>
                  <div
                    class="event-details"
                  >{{conference.secondaryProductDate}}</div>
                  <div class="event-details">{{conference.time}}</div>
                </div>
              </label>
            {{/each}}
          </div>

          <div class="control-group input-group">
            <label for="company-name">{{htmlSafe
                this.siteSettings.conference_registration_company_label
              }}
              <span class="required">*</span></label>
            <TextField
              @value={{this.companyName}}
              @id="company-name"
              @maxlength="255"
              @translatedPlaceholder="Company"
            />
          </div>
          <div class="control-group input-group">
            <label for="title-field">{{htmlSafe
                this.siteSettings.conference_registration_title_label
              }}
              <span class="required">*</span></label>
            <ComboBox
              @content={{this.titles}}
              @id="title-field"
              @value={{this.selectedTitle}}
              @onChange={{this.onChangeTitle}}
              class="relative-time-intervals"
            />

          </div>

          <div class="control-group input-group">
            <label for="country-field">{{htmlSafe
                this.siteSettings.conference_registration_country_label
              }}
              <span class="required">*</span></label>
            <ComboBox
              @content={{countryList}}
              @id="country-field"
              @value={{this.selectedCountry}}
              @onChange={{this.onChangeCountry}}
              class="country-list"
            />
          </div>

          <div class="form-group tos">
            <DToggleSwitch
              {{on "click" this.toggleTos}}
              @state={{this.acceptedTos}}
            />

            <div class="label">
              <a
                href="#"
                target="_blank"
                rel="noopener noreferrer"
              >
              By
              <span role="button" {{on "click" this.toggleTos}}>clicking
                register, you understand and agree to
              </span>
              our Privacy Statement
              </a>
            </div>

          </div>

          <div class="form-group tou">
            <a
              href="#"
              target="_blank"
              rel="noopener noreferrer"
            >Terms of Use</a>
          </div>
          <div class="form-group">
            {{#unless this.isLoading}}
              <DButton
                @action={{this.completeRegistration}}
                class="btn-primary large"
              >Register</DButton>
            {{/unless}}
          </div>
        </div>
      </div>
    {{/if}}

    {{#if this.shouldRenderIntro}}
      <div class="info-box">
        <img class="banner" src={{this.conference.banner}} alt="banner" />
        <div class="row">
          <h1>{{htmlSafe
              this.siteSettings.conference_signup_registration_title
            }}</h1>
          {{htmlSafe
            this.siteSettings.conference_signup_registration_description
          }}
        </div>

        <div class="row form">
          <div class="form-group">
            {{#if this.currentUser}}
              <DButton
                @action={{this.passIntro}}
                class="btn-primary large"
              >Continue</DButton>
            {{else}}
              <DButton class="btn-primary large" @action={{this.passIntro}}>Sign
                in to register</DButton>
            {{/if}}
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
