# frozen_string_literal: true

module Jobs
  class AnswerSimilarQuestions < ::Jobs::Base
    def execute(args)
      return false unless SiteSetting.solved_enabled

      solved_post = Post.find(args[:post_id])
      user = solved_post.user
      guardian = Guardian.new(Discourse.system_user)
      summary = UserSummary.new(user, guardian)
      solved_count = summary.solved_count

      if (
           SiteSetting.send_solved_pm_first_n_time >= solved_count ||
             (solved_count % SiteSetting.send_solved_pm_after_every_n_time) == 0
         )
        topic = solved_post.topic
        suggested_topics = TopicQuery.new(user).list_suggested_for(topic)

        # send a PM to user to recommend similar topics to answer
        if suggested_topics.topics.length > 1 &&
             !!user.custom_fields[DiscourseLivestream::USER_CUSTOM_FIELD_NAME] == false
          raw = I18n.t("answer_similar_questions.message").dup
          suggested_topics.topics.each { |suggested_topic| raw << "\n\n#{suggested_topic.url}" }
          raw << "\n\n#{I18n.t("answer_similar_questions.unsubscribe", base_url: Discourse.base_url)}"

          PostCreator.create!(
            User.find(-2),
            title: I18n.t("answer_similar_questions.title"),
            raw: raw,
            archetype: Archetype.private_message,
            target_usernames: [user.username],
            skip_validations: true,
          )
        end
      end
    end
  end
end
