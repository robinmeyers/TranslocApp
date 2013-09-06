class AddPasswordDigestToResearchers < ActiveRecord::Migration
  def change
    add_column :researchers, :password_digest, :string
  end
end
