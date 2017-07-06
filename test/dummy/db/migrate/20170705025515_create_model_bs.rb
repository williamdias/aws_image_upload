class CreateModelBs < ActiveRecord::Migration[5.0]
  def change
    create_table :model_bs do |t|

      t.timestamps
    end
  end
end
