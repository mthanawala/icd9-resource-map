class CreateCodes < ActiveRecord::Migration
  def change
    create_table :codes do |t|
      t.text :name
      t.text :type
      t.text :revision
      t.text :description
      t.text :url

      t.timestamps null: false
    end
  end
end
