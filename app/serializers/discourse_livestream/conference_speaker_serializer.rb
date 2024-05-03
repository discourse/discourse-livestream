# frozen_string_literal: true
module DiscourseLivestream
  class ::ConferenceSpeakerSerializer < BasicUserSerializer
    attributes :title

    def title
      object.user_fields[SiteSetting.speaker_title_user_field_id]
    end
  end
end
