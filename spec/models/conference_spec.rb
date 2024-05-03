# frozen_string_literal: true
RSpec.describe DiscourseLivestream::Conference, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:category) }
    it do
      is_expected.to have_many(:conference_attendees).with_foreign_key(
        "discourse_conference_id",
      ).class_name("DiscourseLivestream::ConferenceAttendee")
    end
  end

  describe "when Conference is destroyed" do
    it "destroys the associated ConferenceAttendees but not the Users" do
      conference = Fabricate(:conference)
      user1 = Fabricate(:user)
      user2 = Fabricate(:user)
      Fabricate(:conference_attendee, conference: conference, user: user1)
      Fabricate(:conference_attendee, conference: conference, user: user2)

      expect { conference.destroy }.to change(DiscourseLivestream::ConferenceAttendee, :count).from(
        2,
      ).to(0)
      expect(User.exists?(user1.id)).to be true
      expect(User.exists?(user2.id)).to be true
    end

    it "does not destroy the associated Category" do
      category = Fabricate(:category)
      conference = Fabricate(:conference, category: category)

      expect { conference.destroy }.not_to change { Category.exists?(category.id) }.from(true)
    end
  end
end
