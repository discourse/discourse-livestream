import { render } from "@ember/test-helpers";
import { setupRenderingTest } from "ember-qunit";
import { module, test } from "qunit";
import ResponsiveLivestreamChatIcon from "discourse/plugins/discourse-livestream/discourse/components/responsive-livestream-chat-icon";

module(
  "Integration | Component | ResponsiveLivestreamChatIcon",
  function (hooks) {
    setupRenderingTest(hooks);

    test("it shows the icon when viewport is small and topic has chat channel", async function (assert) {
      const capabilities = this.owner.lookup("service:capabilities");
      const topicController = this.owner.lookup("controller:topic");

      capabilities.viewport = { lg: false };

      topicController.model = { chat_channel_id: 123 };

      await render(<template><ResponsiveLivestreamChatIcon /></template>);

      assert
        .dom(".livestream-header-icon")
        .exists("Icon shows on mobile with chat channel");
    });

    test("it hides the icon when viewport is large", async function (assert) {
      const capabilities = this.owner.lookup("service:capabilities");
      const topicController = this.owner.lookup("controller:topic");

      capabilities.viewport = { lg: true };

      topicController.model = { chat_channel_id: 123 };

      await render(<template><ResponsiveLivestreamChatIcon /></template>);

      assert
        .dom(".livestream-header-icon")
        .doesNotExist("Icon hidden on desktop");
    });

    test("it hides the icon when topic has no chat channel", async function (assert) {
      const capabilities = this.owner.lookup("service:capabilities");
      const topicController = this.owner.lookup("controller:topic");

      capabilities.viewport = { lg: false };

      topicController.model = { chat_channel_id: null };

      await render(<template><ResponsiveLivestreamChatIcon /></template>);

      assert
        .dom(".livestream-header-icon")
        .doesNotExist("Icon hidden when no chat channel");
    });
  }
);
