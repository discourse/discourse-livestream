import { withPluginApi } from "discourse/lib/plugin-api";

function showCustomBBCode(isGoing = false) {
  const displayStyle = !isGoing ? "block" : "none";
  const hiddenStyle = isGoing ? "block" : "none";

  document.querySelectorAll(".cooked .preview").forEach((e) => {
    e.style.setProperty("display", displayStyle, "important");
  });

  document.querySelectorAll(".cooked .hidden").forEach((e) => {
    e.style.setProperty("display", hiddenStyle, "important");
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
  const applicationController = container.lookup("controller:application");
  const currentUser = container.lookup("service:current-user");
  const store = container.lookup("service:store");
  const topic = container.lookup("controller:topic");
  const chatChannelsManager = container.lookup("service:chat-channels-manager");
  const chatService = container.lookup("service:chat");
  const chatSubscriptionsManager = container.lookup(
    "service:chatSubscriptionsManager"
  );
  const appEvents = container.lookup("service:appEvents");

  if (!currentUser || !chatService.userCanChat) {
    return;
  }

  appEvents.on("calendar:update-invitee-status", (data) => {
    onAcceptInvite({
      ...data,
      chatChannelsManager,
      topic,
      chatSubscriptionsManager,
      chatService,
    });
  });

  appEvents.on("calendar:create-invitee-status", (data) => {
    onAcceptInvite({
      ...data,
      chatChannelsManager,
      topic,
      chatSubscriptionsManager,
      chatService,
    });
  });

  appEvents.on("calendar:invitee-left-event", (data) => {
    onAcceptInvite({
      ...data,
      chatChannelsManager,
      topic,
      chatSubscriptionsManager,
      chatService,
    });
  });

  api.onPageChange((url) => {
    const allowedPaths = siteSettings.embeddable_chat_allowed_paths.split("|");

    // non livestream topics
    if (
      allowedPaths.every(
        (path) => !url.includes(path) && !url.startsWith(path)
      ) ||
      !topic?.model?.chat_channel_id
    ) {
      return false;
    }

    updateEventStylesByStatus(topic, store, currentUser);
  });
}

async function updateEventStylesByStatus(topic, store, currentUser) {
  let isGoing;
  try {
    const topicPost = parseInt(
      document.getElementById("post_1").dataset.postId
    );
    const attendees = await store.findAll("discourse-post-event-invitee", {
      undefined,
      post_id: topicPost,
      type: "going",
    });
    isGoing = attendees.content.some(
      (attendee) => attendee.user.id === currentUser.id
    );
    showCustomBBCode(isGoing);
  } finally {
    if (!isGoing) {
      document.body.classList.remove("confirmed-event-assistance");
    } else {
      document.body.classList.add("confirmed-event-assistance");
    }
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
