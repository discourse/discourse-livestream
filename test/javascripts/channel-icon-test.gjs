import { click, render } from "@ember/test-helpers";
import { setupRenderingTest } from "ember-qunit";
import { module, test } from "qunit";
import sinon from "sinon";
import MobileLivestreamChatIcon from "discourse/plugins/discourse-livestream/discourse/components/mobile-livestream-chat-icon";
import MobileEmbeddableChatModal from "discourse/plugins/discourse-livestream/discourse/components/modal/mobile-embeddable-chat-modal";

module("Integration | Component | MobileLivestreamChatIcon", function (hooks) {
  setupRenderingTest(hooks);

  test("it renders", async function (assert) {
    await render(<template><MobileLivestreamChatIcon /></template>);
    assert.dom(".livestream-header-icon").exists();
    assert.dom("button").hasClass("icon");
  });

  test("it opens the chat modal if enable_modal_chat_on_mobile is true", async function (assert) {
    const modalService = this.owner.lookup("service:modal");
    const showSpy = sinon.spy(modalService, "show");

    this.owner.lookup("service:site-settings").enable_modal_chat_on_mobile = true;

    await render(<template><MobileLivestreamChatIcon /></template>);
    await click("button");

    assert.ok(showSpy.calledWith(MobileEmbeddableChatModal));
  });

  test("it toggles chat visibility if enable_modal_chat_on_mobile is false", async function (assert) {
    this.owner.lookup(
      "service:site-settings"
    ).enable_modal_chat_on_mobile = false;
    const embeddableChatService = this.owner.lookup("service:embeddable-chat");

    assert.false(
      embeddableChatService.isMobileChatVisible,
      "Initial state isMobileChatVisible is false"
    );

    await render(<template><MobileLivestreamChatIcon /></template>);
    await click("button");

    assert.true(
      embeddableChatService.isMobileChatVisible,
      "isMobileChatVisible is true after clicking button"
    );

    await click("button");

    assert.false(
      embeddableChatService.isMobileChatVisible,
      "isMobileChatVisible is false after clicking button again"
    );
  });
});
