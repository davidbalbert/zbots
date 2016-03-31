class CreateCommands < ActiveRecord::Migration[5.0]
  def change
    create_table :commands do |t|
      t.references :bot, index: true, foreign_key: true
      t.string :name
      t.boolean :builtin, default: false
      t.string :method_name
      t.string :docs
      t.text :body

      t.timestamps
    end

    add_index :commands, [:bot_id, :name]
  end
end
