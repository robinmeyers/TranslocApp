class Junction < ActiveRecord::Base
  belongs_to :library
  default_scope -> { order('rname ASC', 'junction ASC') }
  validates :library_id, presence: true
end
