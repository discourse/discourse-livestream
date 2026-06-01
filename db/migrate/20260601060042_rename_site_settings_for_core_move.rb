# frozen_string_literal: true
class RenameSiteSettingsForCoreMove < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      UPDATE site_settings
      SET name = 'discourse_livestream_embeddable_chat_allowed_paths'
      WHERE name = 'embeddable_chat_allowed_paths'
    SQL

    execute <<~SQL
      UPDATE site_settings
      SET name = 'discourse_livestream_enable_modal_chat_on_mobile'
      WHERE name = 'enable_modal_chat_on_mobile'
    SQL

    execute <<~SQL
      UPDATE site_settings
      SET name = 'discourse_livestream_chat_allowed_groups'
      WHERE name = 'livestream_chat_allowed_groups'
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
