# frozen_string_literal: true

module Jobs
  class MarkAsSolution < ::Jobs::Scheduled
    every 14.days

    def execute(_args = nil)
      return false unless SiteSetting.solved_enabled
      Rails.logger.warn("Running scheduled job to send notifications to mark a post a solution.")

      unsolved_topic_ids = []

      if SiteSetting.allow_solved_on_all_topics
        unsolved_topic_ids = unsolved_topic_ids.push(*Topic.pluck(:id))
      else
        category_ids =
          CategoryCustomField.where(name: "enable_accepted_answers", value: "true").pluck(
            :category_id,
          )

        unsolved_topic_ids =
          unsolved_topic_ids.push(*Topic.where(category_id: category_ids).pluck(:id))

        if SiteSetting.enable_solved_tags.present?
          allowed_tags_ids = Tag.where_name(SiteSetting.enable_solved_tags.split("|")).pluck(:id)
          unsolved_topic_ids =
            unsolved_topic_ids.push(
              *TopicTag.where(tag_id: allowed_tags_ids).distinct.pluck(:topic_id),
            )
        end
      end

      solved_topic_ids = TopicCustomField.where(name: "accepted_answer_post_id").pluck(:topic_id)
      unsolved_topic_ids = unsolved_topic_ids - solved_topic_ids if solved_topic_ids.present?

      unsolved_topics =
        Topic
          .listable_topics
          .where(id: unsolved_topic_ids)
          .where(closed: false, archived: false, visible: true)
          .where("posts_count > 0")
          .where("last_post_user_id <> user_id")
          .where("last_posted_at > ?", SiteSetting.remind_mark_solution_last_post_age.days.ago)

      unsolved_topics.each do |topic|
        if (topic&.last_posted_at || Date.today) <
             SiteSetting.remind_mark_solution_after_days.days.ago
          # create a new reminder PM
          PostCreator.create!(
            User.find(-2),
            title: I18n.t("mark_as_solution.title"),
            raw: "#{I18n.t("mark_as_solution.message")}\n\n#{topic.url}",
            archetype: Archetype.private_message,
            target_usernames: [topic.user.username],
            skip_validations: true,
          )
        end
      end
    end
  end
end
