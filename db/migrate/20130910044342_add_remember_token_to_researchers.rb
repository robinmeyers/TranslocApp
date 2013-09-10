class AddRememberTokenToResearchers < ActiveRecord::Migration
  def change
    add_column :researchers, :remember_token, :string
    add_index  :researchers, :remember_token
  end
end
