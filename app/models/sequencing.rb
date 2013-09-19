class Sequencing < ActiveRecord::Base

  has_many :experiments

  default_scope -> { order('completed_on DESC') }
  validates :run, presence: true, uniqueness: { case_sensitive: false }

  self.per_page = 10

end
