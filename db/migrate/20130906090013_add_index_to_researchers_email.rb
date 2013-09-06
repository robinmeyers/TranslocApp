class AddIndexToResearchersEmail < ActiveRecord::Migration
  def change
    add_index :researchers, :email, unique: true
  end
end
