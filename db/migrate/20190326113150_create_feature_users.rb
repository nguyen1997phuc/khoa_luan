class CreateFeatureUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :feature_users do |t|
      t.references :user, foreign_key: true
      t.references :feature, foreign_key: true

      t.timestamps
    end
  end
end
