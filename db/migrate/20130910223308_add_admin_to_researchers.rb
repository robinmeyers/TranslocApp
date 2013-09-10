class AddAdminToResearchers < ActiveRecord::Migration
  def change
    add_column :researchers, :admin, :boolean, default: false
  end
end
