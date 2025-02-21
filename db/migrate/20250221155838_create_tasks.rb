class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks, id: :string, primary_key: :id do |t|
      t.string :title, null: false
      t.text :description
      t.datetime :due_date
      t.datetime :completed_at
      t.boolean :is_completed, default: false, null: false
      t.integer :priority, default: 1, null: false

      t.timestamps
    end
  end
end
