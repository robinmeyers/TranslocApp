class Sequencing < ActiveRecord::Base

  has_many :libraries

  default_scope -> { order('completed_on DESC') }
  scope :uncompleted, -> { where(completed_on: nil) }
  scope :completed, -> { where.not(completed_on: nil) }
  validates :run, presence: true, uniqueness: { case_sensitive: false }

  self.per_page = 10

end
