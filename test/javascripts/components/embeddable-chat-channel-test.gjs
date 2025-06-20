import { settled, waitFor, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";
import pretender, { response } from "discourse/tests/helpers/create-pretender";
import { PLUGIN_API_VERSION, withPluginApi } from "discourse/lib/plugin-api";

acceptance("Embeddable Chat Channel", function (needs) {
  needs.site();
  needs.user({ has_chat_enabled: true });
  needs.settings({
    discourse_live_chat_enabled: true,
    chat_enabled: true,
    enable_rich_text_paste: true,
  });

  needs.pretender((server, helper) => {
    const channel1 = {
      id: 1,
      title: "Channel 1",
      description: "First test channel",
      chatable_type: "Category",
      chatable_id: 1,
      status: "open",
      last_message_sent_at: new Date().toISOString(),
      current_user_membership: {
        muted: false,
        following: true,
      },
      meta: {
        message_bus_last_ids: {
          new_mentions: 0,
        },
      },
    };

    const channel2 = {
      id: 2,
      title: "Channel 2",
      description: "Second test channel",
      chatable_type: "Category",
      chatable_id: 2,
      status: "open",
      last_message_sent_at: new Date().toISOString(),
      current_user_membership: {
        muted: false,
        following: true,
      },
      meta: {
        message_bus_last_ids: {
          new_mentions: 0,
        },
      },
    };

    function topicResponse(id) {
      const chatChannelId = id === 1 ? 1 : 2;
      const postId = id + 100;
      const username = "jean.perez";

      return helper.response({
        id,
        title: `Livestream Topic ${id}`,
        fancy_title: `Livestream Topic ${id}`,
        posts_count: 1,
        created_at: "2025-06-20T04:04:44.230Z",
        views: 0,
        reply_count: 0,
        like_count: 0,
        last_posted_at: "2025-06-20T04:04:44.320Z",
        visible: true,
        closed: false,
        archived: false,
        has_summary: false,
        archetype: "regular",
        slug: `livestream-topic-${id}`,
        category_id: 4,
        word_count: 114,
        deleted_at: null,
        user_id: 1,
        featured_link: null,
        pinned_globally: false,
        pinned_at: null,
        pinned_until: null,
        image_url: "https://local.vanguardheroesgame.com/uploads/default/optimized/1X/6580b7043f92a2068835e8354de0360764d6988a_2_1024x576.jpeg",
        slow_mode_seconds: 0,
        draft: null,
        draft_key: `topic_${id}`,
        draft_sequence: 3,
        posted: true,
        unpinned: null,
        pinned: false,
        current_post_number: 1,
        highest_post_number: 1,
        last_read_post_number: 1,
        last_read_post_id: postId,
        deleted_by: null,
        has_deleted: false,
        actions_summary: [
          { id: 4, count: 0, hidden: false, can_act: true },
          { id: 8, count: 0, hidden: false, can_act: true },
          { id: 10, count: 0, hidden: false, can_act: true },
          { id: 7, count: 0, hidden: false, can_act: true }
        ],
        chunk_size: 20,
        bookmarked: false,
        bookmarks: [],
        bookmarksWereChanged: false,
        topic_timer: null,
        message_bus_last_id: 8,
        participant_count: 1,
        show_read_indicator: false,
        tags: ["livestream"],
        tags_descriptions: {},
        chat_channel_id: chatChannelId,
        livestream_starts_at: new Date().toISOString(),
        livestream_ends_at: new Date(Date.now() + 86400000).toISOString(),
        event_starts_at: "2025-06-24 03:31:00",
        event_ends_at: null,

        post_stream: {
          posts: [
            {
              id: postId,
              name: null,
              username: username,
              avatar_template: "/letter_avatar_proxy/v4/letter/j/7ea924/{size}.png",
              created_at: "2025-06-20T04:04:44.320Z",
              cooked: "<p>Test content</p>",
              post_number: 1,
              post_type: 1,
              posts_count: 1,
              updated_at: "2025-06-20T04:04:55.962Z",
              reply_count: 0,
              reply_to_post_number: null,
              quote_count: 0,
              incoming_link_count: 105,
              reads: 1,
              readers_count: 0,
              score: 480.2,
              yours: true,
              topic_id: id,
              topic_slug: `livestream-topic-${id}`,
              bookmarked: false,
              actions_summary: [
                { id: 3, can_act: true },
                { id: 4, can_act: true },
                { id: 8, can_act: true },
                { id: 10, can_act: true },
                { id: 7, can_act: true }
              ],
              moderator: true,
              admin: true,
              staff: true,
              user_id: 1,
              hidden: false,
              trust_level: 1,
              deleted_at: null,
              user_deleted: false,
              can_edit: true,
              can_delete: false,
              can_recover: false,
              can_wiki: true,
              read: true,
              wiki: false,
              reviewable_id: 0,
              reviewable_score_count: 0,
              reviewable_score_pending_count: 0
            }
          ],
          stream: [postId]
        },

        timeline_lookup: [[1, 0]],

        details: {
          created_by: {
            id: 1,
            username: username,
            name: null,
            avatar_template: "/letter_avatar_proxy/v4/letter/j/7ea924/{size}.png"
          },
          last_poster: {
            id: 1,
            username: username,
            name: null,
            avatar_template: "/letter_avatar_proxy/v4/letter/j/7ea924/{size}.png"
          },
          participants: [
            {
              id: 1,
              username: username,
              name: null,
              avatar_template: "/letter_avatar_proxy/v4/letter/j/7ea924/{size}.png",
              post_count: 1,
              primary_group_name: null,
              flair_name: null,
              flair_url: null,
              flair_color: null,
              flair_bg_color: null,
              flair_group_id: null,
              admin: true,
              moderator: true,
              trust_level: 1
            }
          ],
          can_edit: true,
          notification_level: 1,
          notifications_reason_id: 2,
          can_move_posts: true,
          can_delete: true,
          can_remove_allowed_users: true,
          can_invite_to: true,
          can_create_post: true,
          can_reply_as_new_topic: true,
          can_flag_topic: true,
          can_convert_topic: true,
          can_review_topic: true,
          can_close_topic: true,
          can_split_merge_topic: true,
          can_edit_staff_notes: true,
          can_toggle_topic_visibility: true,
          can_pin_unpin_topic: true,
          can_moderate_category: true,
          can_remove_self_id: 1
        }
      });
    }
    // Handle both URL patterns for topics
    server.get("/t/:slug/:id.json", (request) => {
      const id = parseInt(request.params.id, 10);
      return topicResponse(id);
    });

    // Add this handler for direct ID-based topic requests
    server.get("/t/:id.json", (request) => {
      const id = parseInt(request.params.id, 10);
      return topicResponse(id);
    });

    server.get("/chat/:id/messages.json", () =>
      helper.response({ chat_messages: [], meta: {} })
    );

    server.get("/chat/api/channels/:id", (request) => {
      const channelId = parseInt(request.params.id, 10);
      return helper.response(channelId === 1 ? channel1 : channel2);
    });

    server.get("/chat/api/channels/:id/messages", () => {
      return helper.response({
        messages: [],
        meta: {
          can_load_more_past: false,
          can_load_more_future: false,
        },
      });
    });

    server.get("/chat/api/me/channels", () =>
      helper.response({
        public_channels: [channel1, channel2],
        direct_message_channels: [],
        meta: {
          message_bus_last_ids: {
            "/chat/online": 0,
            "/chat/mention-notification": 0,
            "/chat/channel-edits": 0,
            "/chat/channel-metadata": 0,
            "/chat/channels-tracking": 0,
            "/chat/new-channel": 0,
            "/chat/channel-status": 0,
            "/chat/channel/1": 0,
            "/chat/channel/2": 0,
          },
        },
        global_presence_channel_state: {
          user_count: 0,
          last_message_id: 0,
          users: [],
        },
        tracking: {
          channel_tracking: {
            1: {
              unread_count: 0,
              mention_count: 0,
              last_read_message_id: 0,
            },
            2: {
              unread_count: 0,
              mention_count: 0,
              last_read_message_id: 0,
            },
          },
          thread_tracking: {},
        },
        unread_thread_overview: {},
        chat_state: {
          user_silenced: false,
        },
      })
    );
  });

  needs.hooks.beforeEach(function () {

    if (!this.owner.hasRegistration("service:site")) {
      this.owner.register("service:site", class extends Service {
        categories = [];
      });
    }
    
    Object.defineProperty(this, "siteSettings", {
      get: () => this.container.lookup("service:site-settings"),
    });
    Object.defineProperty(this, "chatService", {
      get: () => this.container.lookup("service:chat"),
    });

    Object.defineProperty(this, "chatChannelsManager", {
      get: () => this.container.lookup("service:chat-channels-manager"),
    });

    Object.defineProperty(this, "embeddableChat", {
      get: () => this.container.lookup("service:embeddable-chat"),
    });

    // Set up embeddableChat service to recognize livestream topics
    const embeddableChat = this.embeddableChat;
    embeddableChat.topicHasLivestreamTag = (topic) => {
      return topic && topic.tags && topic.tags.includes("livestream");
    };
  });

  test("it loads the initial channel when visiting a URL", async function (assert) {
    // return await withPluginApi(PLUGIN_API_VERSION, async (api) => {
    //   const { categories } = this.container.lookup("service:site");
    //   const { siteSettings } = this.container.lookup("service:site-settings");

      await visit("/t/livestream-topic-1/1");
      await waitFor("#custom-chat-container .chat-drawer");

      assert.dom(".chat-drawer").exists();


      assert.strictEqual(
        this.embeddableChat.activeChannel?.id,
        1,
        "activeChannel is set correctly from topic's chat_channel_id"
      );
    // });
  });

  // test("it updates the channel when navigating to a different URL", async function (assert) {
  //   await visit("/t/livestream-topic-1/1");
  //   await waitFor("#custom-chat-container .chat-drawer");
  //
  //   assert.strictEqual(
  //     this.embeddableChat.activeChannel?.id,
  //     1,
  //     "initially loads channel 1 from topic"
  //   );
  //
  //   await visit("/t/livestream-topic-2/2");
  //   await settled();
  //
  //   assert.strictEqual(
  //     this.embeddableChat.activeChannel?.id,
  //     2,
  //     "updates to channel 2 when navigating to a different topic"
  //   );
  // });
  //
  // test("it properly handles URL-based channel switching", async function (assert) {
  //   await visit("/t/livestream-topic-1/1");
  //   await waitFor("#custom-chat-container .chat-drawer");
  //
  //   const originalChannel = this.embeddableChat.activeChannel;
  //   assert.ok(originalChannel, "channel 1 is loaded from the topic");
  //
  //   await visit("/t/livestream-topic-2/2");
  //   await settled();
  //
  //   assert.notStrictEqual(
  //     this.embeddableChat.activeChannel,
  //     originalChannel,
  //     "channel reference has changed after URL navigation"
  //   );
  //   assert.strictEqual(
  //     this.embeddableChat.activeChannel?.id,
  //     2,
  //     "channel 2 is active after URL change"
  //   );
  // });
});
