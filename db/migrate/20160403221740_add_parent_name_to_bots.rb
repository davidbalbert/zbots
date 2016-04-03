class AddParentNameToBots < ActiveRecord::Migration[5.0]
  def change
    add_column :bots, :parent_name, :string
  end
end
