class AddDescriptionToBots < ActiveRecord::Migration[5.0]
  def change
    add_column :bots, :description, :string
  end
end
