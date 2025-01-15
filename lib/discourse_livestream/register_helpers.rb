# frozen_string_literal: true

module DiscourseLivestream
  module RegisterHelpers
    def user_allowed_in_livestream_chat?(user)
      allowed_groups = SiteSetting.livestream_chat_allowed_groups.split("|").map(&:to_i)
      (allowed_groups & user.groups.ids).any?
    end
  end
end
