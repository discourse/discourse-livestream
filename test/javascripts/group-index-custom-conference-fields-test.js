import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import { fixturesByUrl } from "discourse/tests/helpers/create-pretender";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";
import { cloneJSON } from "discourse-common/lib/object";

acceptance("Group Members Index - Custom Conference Fields", function (needs) {
  needs.user();

  needs.settings({
    conference_category_id: "32",
    conference_group_name: "awesome-conf",
  });

  needs.pretender((server, helper) => {
    server.get("/groups/awesome-conf.json", () => {
      const response = cloneJSON(fixturesByUrl["/groups/discourse.json"]);
      response.group.name = "awesome-conf";
      return helper.response(200, response);
    });
    server.get("/chat/api/channels/0", () => helper.response(200, {}));
    server.get("/groups/awesome-conf/members.json", () => {
      const response = cloneJSON(
        fixturesByUrl["/groups/discourse/members.json"]
      );

      response.members = response.members.map((member, index) => {
        return {
          ...member,
          conference_attendances: [
            {
              id: 20 + index,
              selected_conference: "semi_live_april_23",
              company: `company ${index}`,
              country: `country ${index}`,
              title: `title ${index}`,
              discourse_conference_id: 3,
              category_id: 32,
              created_at: "2024-01-25T06:08:01.423Z",
            },
          ],
        };
      });

      return helper.response(200, response);
    });
  });

  test("Verify table headers", async function (assert) {
    await visit("/g/awesome-conf");
    const fields = [
      { id: "selected_conference", title: "Selected Region" },
      { id: "title", title: "Business Title" },
      { id: "company", title: "Company Name" },
      { id: "country", title: "Country" },
      { id: "created_at", title: "Registration time" },
    ];

    fields.forEach((field) => {
      const selector = `.directory-table__column-header--user-field-${field.id}`;
      const message = `shows the ${field.title.toLowerCase()} header`;

      assert.dom(selector).hasText(field.title, message);
    });

    const rows = document.querySelectorAll(".directory-table__row");
    rows.forEach((row, index) => {
      assert
        .dom(
          ".directory-table__cell--user-field-company .directory-table__value",
          row
        )
        .includesText(
          `company ${index}`,
          `it shows company value for member at row ${index + 1}`
        );
    });
  });

  test("Verify table rows", async function (assert) {
    await visit("/g/awesome-conf");

    const fields = [
      { id: "title", text: (index) => `title ${index}` },
      { id: "company", text: (index) => `company ${index}` },
      { id: "country", text: (index) => `country ${index}` },
    ];

    const rows = document.querySelectorAll(".directory-table__row");
    rows.forEach((row, rowIndex) => {
      fields.forEach(({ id, text }) => {
        const expectedText = text(rowIndex);
        const message = `it shows ${id.replace(
          /_/g,
          " "
        )} value for member at row ${rowIndex + 1}`;

        assert
          .dom(
            `.directory-table__cell--user-field-${id} .directory-table__value`,
            row
          )
          .includesText(expectedText, message);
      });
    });
  });
});
