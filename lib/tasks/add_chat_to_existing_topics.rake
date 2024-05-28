# frozen_string_literal: true

desc "Add chat to existing topic"
task "add_chat_to_existing_topics" => :environment do
  Topic
    .includes(:user, :category, :tags)
    .where(category: { slug: "events" }, tags: { name: SiteSetting.topic_livestream_tag })
    .find_each(batch_size: 100) do |topic|
      next if topic.category.blank?
      next unless topic.tags.any? { |tag| tag.name == SiteSetting.topic_livestream_tag }
      if Chat::Channel.exists?(
           topic_id: topic.id,
           chatable_id: topic.category.id,
           chatable_type: "Category",
         )
        next
      end
      begin
        ActiveRecord::Base.transaction { DiscourseLivestream.handle_chat_channel_creation(topic) }
        Rails.logger.info "Chat channel created for topic: #{topic.title}"
      rescue => e
        Rails.logger.error "Failed to create chat channel for topic: #{topic.title}, Error: #{e.message}"
      end
    end
end
