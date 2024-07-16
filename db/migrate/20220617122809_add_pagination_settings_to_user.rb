class AddPaginationSettingsToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :pagination_settings, :json, default: SiteSettings::UserDefaults::PAGINATION
  end
end
