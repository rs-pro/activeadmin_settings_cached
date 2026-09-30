class CreateSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :settings do |t|
      t.string :var, null: false
      t.text :value
      t.timestamps
    end
    add_index :settings, :var, unique: true
  end
end
