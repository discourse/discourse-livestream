# frozen_string_literal: true
RSpec.describe User do
  describe "Associations" do
    it do
      is_expected.to have_many(:conference_attendances)
        .class_name("DiscourseLivestream::ConferenceAttendee")
        .with_foreign_key("user_id")
        .dependent(:destroy)
    end
  end

  describe "when User is destroyed" do
    it "also destroys the associated ConferenceAttendees" do
      user = Fabricate(:user)
      Fabricate(:conference_attendee, user: user)
      Fabricate(:conference_attendee, user: user)

      expect { user.destroy }.to change(DiscourseLivestream::ConferenceAttendee, :count).by(-2)
    end
  end
end
