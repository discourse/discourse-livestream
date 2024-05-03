import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import countryList from "../lib/country-list";

export default class ConferenceGroupTableValueRenderer extends Component {
  @service siteSettings;
  @service conference;

  constructor() {
    super(...arguments);
  }

  get formattedAttendance() {
    const attendance = this.findAttendanceByCategory(
      this.siteSettings.conference_category_id
    );
    return this.formatFields(attendance);
  }

  findAttendanceByCategory(categoryId) {
    return this.args.member.conference_attendances.find(
      ({ category_id }) =>
        parseInt(category_id, 10) === parseInt(categoryId, 10)
    );
  }

  formatFields(attendance) {
    const fields = [
      "selected_conference",
      "title",
      "company",
      "country",
      "created_at",
    ];

    return fields.map((field) => {
      return {
        id: `${field}`,
        label: this.formatFieldValue(field, attendance),
        value: this.formatFieldValue(field, attendance),
      };
    });
  }

  formatFieldValue(field, attendance) {
    switch (field) {
      case "country":
        return this.getCountryName(attendance[field]);
      case "selected_conference":
        return this.getConferenceName(attendance[field]);
      case "created_at":
        return moment(attendance[field]).format("YYYY-MM-DD HH:mm:ss");
      default:
        return attendance[field];
    }
  }

  getCountryName(countryId) {
    return countryList.find(({ id }) => id === countryId)?.name || countryId;
  }

  getConferenceName(conferenceId) {
    const conferenceNames = {
      live_april_9: "Week 1, Americas (April 9th)",
      semi_live_april_16: "Week 2, EMEA/IST (April 15th)",
      semi_live_april_23: "Week 3 APAC/AEDT (April 23rd)",
    };
    return conferenceNames[conferenceId] || conferenceId;
  }

  <template>
    {{#if this.conference.isConferenceGroupShowPage}}
      {{#each this.formattedAttendance as |attendance|}}
        <div
          class="directory-table__cell directory-table__cell--user-field-{{attendance.id}}"
        >
          <span class="directory-table__label">
            <span>{{attendance.label}}</span>
          </span>
          <span class="directory-table__value">
            {{attendance.value}}
          </span>
        </div>
      {{/each}}
    {{/if}}
  </template>
}
