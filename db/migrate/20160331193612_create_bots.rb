class CreateBots < ActiveRecord::Migration[5.0]
  def change
    create_table :bots do |t|
      t.string :username
      t.string :api_key
      t.references :parent, index: true
      t.boolean :root, null: false, default: false
      t.boolean :copy, null: false, default: false
      t.jsonb :state, null: false, default: {}
      t.text :code, null: false, default: ""

      t.timestamps
    end

    add_index :bots, :root
    add_index :bots, :copy
  end
end
