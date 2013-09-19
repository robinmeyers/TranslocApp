class Experiment < ActiveRecord::Base

  belongs_to :researcher
  belongs_to :sequencing

  default_scope -> { joins(:sequencing).order('sequencings.completed_on DESC') }

  validates :name, presence: true
  validates :researcher_id, presence: true
  validates :sequencing_id, presence: true
end
