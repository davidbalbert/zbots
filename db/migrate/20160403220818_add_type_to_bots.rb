class AddTypeToBots < ActiveRecord::Migration[5.0]
  def change
    add_column :bots, :type, :string, null: false, default: "Bot"
    remove_column :bots, :copy, :boolean
  end
end
