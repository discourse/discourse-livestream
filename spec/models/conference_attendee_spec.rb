# frozen_string_literal: true
RSpec.describe DiscourseLivestream::ConferenceAttendee, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it do
      is_expected.to belong_to(:conference).class_name(
        "DiscourseLivestream::Conference",
      ).with_foreign_key("discourse_conference_id")
    end
  end

  describe "when ConferenceAttendee is destroyed" do
    let!(:user) { Fabricate(:user) }
    let!(:category) { Fabricate(:category) }
    let!(:conference) { Fabricate(:conference, category: category) }
    let!(:conference_attendee) do
      Fabricate(:conference_attendee, conference: conference, user: user)
    end

    it "does not destroy the associated User" do
      expect { conference_attendee.destroy }.not_to change(User, :count)
      expect(User.exists?(user.id)).to be true
    end

    it "does not destroy the associated Conference" do
      expect { conference_attendee.destroy }.not_to change(DiscourseLivestream::Conference, :count)
      expect(DiscourseLivestream::Conference.exists?(conference.id)).to be true
    end

    it "does not destroy the associated Category" do
      expect { conference_attendee.destroy }.not_to change(Category, :count)
      expect(Category.exists?(category.id)).to be true
    end
  end
end
