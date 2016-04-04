class DeleteParentId < ActiveRecord::Migration[5.0]
  def change
    remove_reference :bots, :parent, index: true
    remove_column :bots, :root, :boolean, default: false

    rename_column :bots, :parent_name, :parent
  end
end
