# frozen_string_literal: true

require "promotion"

RSpec.describe Chat::ChannelMembershipManager do
  describe "plugin_registry working correctly" do
    fab!(:admin)
    fab!(:user) { Fabricate(:user, trust_level: TrustLevel[1]) }
    fab!(:livestream_channel) { Fabricate(:category_channel) }
    fab!(:normal_channel1) { Fabricate(:category_channel) }
    fab!(:normal_channel2) { Fabricate(:category_channel) }
    fab!(:topic) { Fabricate(:topic, user: user) }
    fab!(:topic_chat_channel) do
      Fabricate(:topic_chat_channel, topic: topic, chat_channel: livestream_channel)
    end
    fab!(:first_post) { Fabricate(:post, topic: topic) }

    fab!(:normal_membership1) do
      Fabricate(
        :user_chat_channel_membership,
        user: user,
        chat_channel: normal_channel1,
        following: false,
      )
    end
    fab!(:normal_membership2) do
      Fabricate(:user_chat_channel_membership, user: user, chat_channel: normal_channel2)
    end

    before do
      SiteSetting.discourse_livestream_enabled = true
      SiteSetting.calendar_enabled = true
      SiteSetting.discourse_post_event_enabled = true
    end

    context "when chat is a TopicChatChannel" do
      fab!(:event) do
        Fabricate(
          :event,
          post: first_post,
          original_starts_at: Time.now + 1.hours,
          original_ends_at: Time.now + 2.hours,
        )
      end

      fab!(:livestream_membership) do
        Fabricate(:user_chat_channel_membership, user: user, chat_channel: livestream_channel)
      end

      describe "when user is attending" do
        fab!(:post_event_invitee) do
          Fabricate(
            :post_event_invitee,
            event: event,
            user: user,
            status: DiscoursePostEvent::Invitee.statuses[:going],
          )
        end

        describe "when user in allow listed to chat group" do
          before do
            SiteSetting.livestream_chat_allowed_groups = "#{Group::AUTO_GROUPS[:trust_level_1]}"
          end

          describe "when user is not following the channel" do
            it "makes the user follow the channel and returns the appropiate channel object" do
              livestream_membership.following = false
              livestream_membership.save

              memberships = Chat::ChannelMembershipManager.all_for_user(user)

              livestream_membership.reload
              normal_membership1.reload
              normal_membership2.reload

              expect(livestream_membership.following).to eq(true)
              expect(normal_membership1.following).to eq(false)
              expect(normal_membership2.following).to eq(true)
              expect(memberships.count).to eq(3)
            end
          end

          describe "when user is following the channel" do
            it "leaves things as are" do
              memberships = Chat::ChannelMembershipManager.all_for_user(user)

              livestream_membership.reload
              normal_membership1.reload
              normal_membership2.reload

              expect(livestream_membership.following).to eq(true)
              expect(normal_membership1.following).to eq(false)
              expect(normal_membership2.following).to eq(true)
              expect(memberships.count).to eq(3)
            end
          end
        end

        describe "when user not in allow listed to chat group" do
          before do
            SiteSetting.livestream_chat_allowed_groups = "#{Group::AUTO_GROUPS[:trust_level_4]}"
          end

          describe "when user is following the channel" do
            it "makes the user unfollow the channel and returns the appropiate channel object" do
              memberships = Chat::ChannelMembershipManager.all_for_user(user)

              livestream_membership.reload
              normal_membership1.reload
              normal_membership2.reload

              expect(livestream_membership.following).to eq(false)
              expect(normal_membership1.following).to eq(false)
              expect(normal_membership2.following).to eq(true)
              expect(memberships.count).to eq(3)
            end
          end

          describe "when user is not following the channel" do
            it "leaves things as aret" do
              livestream_membership.following = false
              livestream_membership.save

              memberships = Chat::ChannelMembershipManager.all_for_user(user)

              livestream_membership.reload
              normal_membership1.reload
              normal_membership2.reload

              expect(livestream_membership.following).to eq(false)
              expect(normal_membership1.following).to eq(false)
              expect(normal_membership2.following).to eq(true)
              expect(memberships.count).to eq(3)
            end
          end
        end
      end
    end
  end
end
