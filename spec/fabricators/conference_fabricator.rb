# frozen_string_literal: true

Fabricator(:conference, class_name: "DiscourseLivestream::Conference") do
  title { sequence(:title) { |n| "Conference Title #{n}" } }
  start_date { 1.week.from_now }
  end_date { 2.weeks.from_now }
  category
end
