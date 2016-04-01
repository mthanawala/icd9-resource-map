class RenameColumns < ActiveRecord::Migration
  def change
    rename_column :codes, :name, :code
    rename_column :codes , :type, :code_type
  end
end
