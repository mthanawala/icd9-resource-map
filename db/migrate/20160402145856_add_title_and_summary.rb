class AddTitleAndSummary < ActiveRecord::Migration
  def change
    add_column :codes, :title, :string
    add_column :codes, :summary, :text
  end
end
