import { later } from "@ember/runloop";
import { withPluginApi } from "discourse/lib/plugin-api";
import { schedule } from "@ember/runloop";

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
  const currentUser = container.lookup("service:current-user");
  const applicationController = container.lookup("controller:application");
  const topic = container.lookup("controller:topic");

  api.onPageChange((url) => {
    const allowedPaths = siteSettings.embeddable_chat_allowed_paths.split("|");

    // non livestream topics
    if (
      allowedPaths.every((path) => !url.includes(path) && !url.startsWith(path))
    ) {
      return false;
    }

    if (!topic?.model?.chat_channel_id) {
      console.log("no channel");
      resetCustomChatStyles();
      applicationController.set("showSidebar", false);
      api.forceSidebarEnabled(false);
    } else {
      console.log("channel");
      applicationController.set("showSidebar", true);
      api.forceSidebarEnabled(true);
      // container.lookup("service:header").hamburgerVisible = true;
      // updateEventStylesByStatus(topic, store, currentUser);
      // if (!document.body.classList.contains("has-sidebar-page")) {
      // applicationController.set("showSidebar", true);
      // applicationController.toggleSidebar();

      // }
      // Chat scrolls to the bottom of the page when the chat channel is loaded
      // this is required for the chat message positioning to be correct.
      // We need to scroll to the top of the page after the chat channel is loaded
      // to avoid the page being rendered and the viewport being scrolled to the bottom.
      // This is not an ideal solution, but it's the best we can do for now
      // later(() => {
      //   document.documentElement.scrollIntoView({
      //     behavior: "smooth",
      //     block: "start",
      //     inline: "start",
      //   });
      // }, 500);
      setCustomChatStyles();
    }
  });
}

function setCustomChatStyles() {
  document.documentElement.classList.add("livestream-present");
  document
    .querySelector(".topic-navigation")
    .style.setProperty("display", "none");
}

function resetCustomChatStyles() {
  document.documentElement.classList.remove("livestream-present");
  document
    .querySelector(".topic-navigation")
    ?.style?.setProperty("display", "block");
  document
    .querySelector(".header-sidebar-toggle")
    ?.style?.setProperty("display", "none");
}

async function updateEventStylesByStatus(topic, store, currentUser) {
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
      // overrideChat(api, container);
    });
  },
};
