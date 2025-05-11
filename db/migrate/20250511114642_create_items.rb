class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :description
      t.references :todo_list, null: false, foreign_key: true
      t.boolean :completed

      t.timestamps
    end
  end
end
