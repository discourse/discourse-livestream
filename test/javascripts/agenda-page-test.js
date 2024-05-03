import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("Conference Agenda", function (needs) {
  needs.user();
  needs.pretender((server, helper) => {
    const agendaResponse = () => {
      const agenda = {
        "United States": {
          "Day 1": {
            "IDN Stage 1": [
              {
                startTime: "2024-04-09T14:00:00.000Z",
                endTime: "2024-04-09T14:15:00.000Z",
                description: "Welcome to Conf",
                topic: "Welcome to Conf",
                speakers: ["Jordan Violet"],
              },
              {
                startTime: "2024-04-09T14:15:00.000Z",
                endTime: "2024-04-09T14:45:00.000Z",
                description: "",
                topic: "Keynote",
                speakers: ["Grady Summers"],
              },
            ],
          },
        },
      };
      return helper.response(200, agenda);
    };
    server.get("/chat/api/channels/0", () => helper.response(200, {}));
    server.get("agenda", agendaResponse);
  });

  test("Visiting agenda and checking content", async function (assert) {
    await visit("/conference/agenda");
    assert
      .dom(".schedule > .time-slot .event .stage-info h2")
      .includesText("Welcome to Conf");
  });
});
