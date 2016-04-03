class AddNameToBots < ActiveRecord::Migration[5.0]
  def change
    add_column :bots, :name, :string
  end
end
