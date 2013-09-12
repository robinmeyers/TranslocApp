class Sequencing < ActiveRecord::Base

  default_scope -> { order('completed_on DESC') }
  validates :run, presence: true, uniqueness: { case_sensitive: false }

  self.per_page = 10

end
