class Experiment < ActiveRecord::Base

  belongs_to :researcher
  belongs_to :sequencing

  validates :researcher_id, presence: true
  validates :sequencing_id, presence: true
end
