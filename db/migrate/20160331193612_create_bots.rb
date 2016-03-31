class CreateBots < ActiveRecord::Migration[5.0]
  def change
    create_table :bots do |t|
      t.string :username
      t.string :api_key
      t.references :parent, index: true
      t.boolean :root, null: false, default: false
      t.boolean :stream_all, null: false, default: false
      t.string :watchword

      t.timestamps
    end

    add_index :bots, :watchword
    add_index :bots, :root
    add_index :bots, :stream_all
  end
end
