import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import TableHeaderToggle from "discourse/components/table-header-toggle";
import { getOwnerWithFallback } from "discourse-common/lib/get-owner";

export default class ConferenceGroupTableHeaderRenderer extends Component {
  @service siteSettings;
  @service conference;
  filteredFields = [
    { id: "selected_conference", title: "Selected Region" },
    { id: "title", title: "Business Title" },
    { id: "company", title: "Company Name" },
    { id: "country", title: "Country" },
    { id: "created_at", title: "Registration time" },
  ];

  fieldNameToFieldIdMap = this.filteredFields.reduce((acc, field) => {
    acc[field.title] = field.id;
    return acc;
  }, {});
  fieldIdToFieldNameMap = this.filteredFields.reduce((acc, field) => {
    acc[field.id] = field.title;
    return acc;
  }, {});

  _groupIndexController = null;

  constructor() {
    super(...arguments);

    if (!this.conference.isConferenceGroupShowPage) {
      return;
    }
    this._groupIndexController = getOwnerWithFallback(this).lookup(
      "controller:group-index"
    );
  }

  get order() {
    return this.fieldIdToFieldNameMap[this.args.order];
  }

  set order(order) {
    this._groupIndexController.set("order", this.fieldNameToFieldIdMap[order]);
  }

  get asc() {
    return this.args.asc;
  }

  set asc(asc) {
    this._groupIndexController.set("asc", asc);
  }

  <template>
    {{#if this.conference.isConferenceGroupShowPage}}
      {{#each this.filteredFields as |userField|}}
        <TableHeaderToggle
          @class="directory-table__column-header--user-field-{{userField.id}}"
          @order={{this.order}}
          @asc={{this.asc}}
          @translated={{true}}
          @field={{userField.title}}
          @automatic={{false}}
        />
      {{/each}}
    {{/if}}
  </template>
}
