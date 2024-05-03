# frozen_string_literal: true
class CreateConferenceAttendeesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_conference_attendees do |t|
      t.integer :user_id, null: false
      t.integer :discourse_conference_id, null: false
      t.string :selected_conference
      t.string :title
      t.string :country
      t.string :company

      t.timestamps
    end

    add_foreign_key :discourse_conference_attendees, :users
    add_foreign_key :discourse_conference_attendees, :conferences
  end
end
