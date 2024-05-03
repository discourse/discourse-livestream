# frozen_string_literal: true
RSpec.describe Category do
  describe "Associations" do
    it do
      is_expected.to have_one(:conference).class_name("DiscourseLivestream::Conference").dependent(
        :destroy,
      )
    end
  end

  describe "when Category is destroyed" do
    it "also destroys the associated Conference" do
      category = Fabricate(:category)
      conference = Fabricate(:conference, category: category)

      expect { category.destroy }.to change {
        DiscourseLivestream::Conference.exists?(conference.id)
      }.from(true).to(false)
    end
  end
end
