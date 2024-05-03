# frozen_string_literal: true

require "rails_helper"

describe Jobs::MarkAsSolution do
  before do
    SiteSetting.solved_enabled = true
    SiteSetting.allow_solved_on_all_topics = true
  end

  describe "#execute" do
    fab!(:user)
    fab!(:topic) { Fabricate(:topic, last_post_user_id: user.id, last_posted_at: 170.days.ago) }
    fab!(:post) { Fabricate(:post, topic: topic, user: user) }

    context "when the topic is not solved" do
      it "should send the PM to user to mark a post as solution" do
        expect { described_class.new.execute({}) }.to change { Topic.count }.by(1)
        expect(Topic.last.title).to eq(I18n.t("mark_as_solution.title"))
      end
    end

    context "when the topic is solved" do
      before { DiscourseSolved.accept_answer!(post, Discourse.system_user) }

      it "should not send the PM to user" do
        expect { described_class.new.execute({}) }.to not_change { Topic.count }
      end
    end
  end
end
