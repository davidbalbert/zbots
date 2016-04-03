class AddNameIndexToBots < ActiveRecord::Migration[5.0]
  def change
    add_index :bots, :name
  end
end
