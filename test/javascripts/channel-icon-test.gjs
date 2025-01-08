import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render, click } from "@ember/test-helpers";
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

  test("it opens the chat modal if modal_mobile_chat_channel_channel is true", async function (assert) {
    const modalService = this.owner.lookup("service:modal");
    const showSpy = sinon.spy(modalService, "show");

    this.owner.lookup("service:site-settings").modal_mobile_chat_channel_channel = true;

    await render(<template><MobileLivestreamChatIcon /></template>);
    await click("button");

    assert.ok(showSpy.calledWith(MobileEmbeddableChatModal));
  });

   test("it toggles chat visibility if modal_mobile_chat_channel_channel is false", async function (assert) {
     this.owner.lookup("service:site-settings").modal_mobile_chat_channel_channel = false;
    const embeddableChatService = this.owner.lookup("service:embeddable-chat");

    assert.strictEqual(
      embeddableChatService.isMobileChatVisible,
      false,
      "Initial state isMobileChatVisible is false"
    );

    await render(<template><MobileLivestreamChatIcon /></template>);
    await click("button");

    assert.strictEqual(
      embeddableChatService.isMobileChatVisible,
      true,
      "isMobileChatVisible is true after clicking button"
    );

    await click("button");

    assert.strictEqual(
      embeddableChatService.isMobileChatVisible,
      false,
      "isMobileChatVisible is false after clicking button again"
    );
  });
});