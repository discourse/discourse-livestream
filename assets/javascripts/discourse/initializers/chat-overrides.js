import { withPluginApi } from "discourse/lib/plugin-api";

function showCustomBBCode(isGoing = false) {
  document.querySelectorAll(".cooked .preview").forEach(function (element) {
    element.style.setProperty(
      "display",
      !isGoing ? "block" : "none",
      "important"
    );
  });

  document.querySelectorAll(".cooked .hidden").forEach(function (element) {
    element.style.setProperty(
      "display",
      isGoing ? "block" : "none",
      "important"
    );
  });
}

async function onAcceptInvite({ status, chatChannelsManager, topic }) {
  if (status === "going") {
    showCustomBBCode(true);

    const channel = await chatChannelsManager.find(topic.model.chat_channel_id);
    chatChannelsManager.follow(channel);
    document.querySelector(".chat-drawer").classList.remove("unconfirmed");
    document.body.classList.add("confirmed-event-assistance");
    return;
  }
  if (status !== "going") {
    showCustomBBCode(false);

    const channel = await chatChannelsManager.find(topic.model.chat_channel_id);
    chatChannelsManager.unfollow(channel);
    document.querySelector(".chat-drawer").classList.add("unconfirmed");
    document.body.classList.remove("confirmed-event-assistance");
  }
}

function overrideChat(api, container) {
  const siteSettings = container.lookup("service:site-settings");
  if (!siteSettings.enable_livestream_chat) {
    return;
  }
  const chatService = container.lookup("service:chat");
  const chatSubscriptionsManager = container.lookup(
    "service:chatSubscriptionsManager"
  );
  const store = container.lookup("service:store");
  const chatChannelsManager = container.lookup("service:chat-channels-manager");
  const appEvents = container.lookup("service:appEvents");
  let topic = container.lookup("controller:topic");
  const currentUser = api.getCurrentUser();

  if (!currentUser || !chatService.userCanChat) {
    return;
  }

  appEvents.on("calendar:update-invitee-status", (data) => {
    onAcceptInvite({
      ...data,
      appEvents,
      chatChannelsManager,
      topic,
      chatSubscriptionsManager,
      chatService,
    });
  });

  appEvents.on("calendar:create-invitee-status", (data) => {
    onAcceptInvite({
      ...data,
      appEvents,
      chatChannelsManager,
      topic,
      chatSubscriptionsManager,
      chatService,
    });
  });

  appEvents.on("calendar:invitee-left-event", (data) => {
    onAcceptInvite({
      ...data,
      appEvents,
      chatChannelsManager,
      topic,
      chatSubscriptionsManager,
      chatService,
    });
  });

  api.onPageChange((url) => {
    const allowedPaths = siteSettings.embeddable_chat_allowed_paths.split("|");

    if (
      allowedPaths.every((path) => !url.includes(path) && !url.startsWith(path))
    ) {
      document.body.classList.remove("custom-chat-enabled");
      appEvents.trigger("chat:toggle-close");
      return;
    }

    if (!topic?.model?.chat_channel_id) {
      // don't show the chat if there is no chat channel
      document
        .querySelector(".embeddable-chat-channel")
        .style.setProperty("display", "none", "important");
    } else {
      updateTopicStylesWithChatChannel(topic, store, currentUser);
    }
  });
}

async function updateTopicStylesWithChatChannel(topic, store, currentUser) {
  let isGoing;
  try {
    const attendees = await store.findAll("discourse-post-event-invitee", {
      undefined,
      post_id: topic.currentPostId,
      type: "going",
    });
    isGoing = attendees.content.some(
      (attendee) => attendee.user.id === currentUser.id
    );
    showCustomBBCode(isGoing);
    document.body.classList.add("custom-chat-enabled");
  } finally {
    if (!isGoing) {
      document.body.classList.remove("confirmed-event-assistance");
    } else {
      document.body.classList.add("confirmed-event-assistance");
    }
    document
      .querySelector(".embeddable-chat-channel")
      .style.setProperty("display", "block", "important");
  }
}

export default {
  name: "discourse-livestream-chat-sidebar",
  initialize(container) {
    withPluginApi("1.8.0", (api) => {
      overrideChat(api, container);
    });
  },
};
