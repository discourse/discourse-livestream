# frozen_string_literal: true

require "rails_helper"

describe Jobs::AnswerSimilarQuestions do
  before { SiteSetting.solved_enabled = true }

  describe "#execute" do
    fab!(:user)
    fab!(:topic) { Fabricate(:topic, last_post_user_id: user.id, last_posted_at: 170.days.ago) }
    fab!(:post) { Fabricate(:post, topic: topic, user: user) }

    before { 5.times { Fabricate(:topic) } }

    it "should send a PM to user suggesting more topics to answer" do
      DiscourseSolved.accept_answer!(post, Discourse.system_user)
      expect { described_class.new.execute({ post_id: post.id }) }.to change { Topic.count }.by(1)
      expect(Topic.last.title).to eq(I18n.t("answer_similar_questions.title"))
    end
  end
end
