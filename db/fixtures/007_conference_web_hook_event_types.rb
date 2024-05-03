# frozen_string_literal: true
WebHookEventType.seed do |b|
  b.id = WebHookEventType::REGISTER_DEV_DAYS_CONFERENCE
  b.name = "register_dev_days_conference"
  b.group = WebHookEventType.groups[:user]
end
