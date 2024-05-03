# frozen_string_literal: true
class CreateConferencesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_conferences do |t|
      t.string :title
      t.datetime :start_date
      t.datetime :end_date
      t.integer :category_id, null: false

      t.timestamps
    end

    add_foreign_key :discourse_conferences, :categories
  end
end
