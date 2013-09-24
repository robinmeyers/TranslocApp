class Experiment < ActiveRecord::Base

  belongs_to :researcher
  belongs_to :sequencing

  before_validation do
    mid.upcase!
    primer.upcase!
    adapter.upcase!
    breaksite.upcase!
  end

  default_scope -> { joins(:sequencing).order('sequencings.completed_on DESC') }

  validates :name, presence: true, length: {maximum: 50},
                   uniqueness: { scope: :sequencing_id }
  validates :researcher_id, presence: true
  validates :sequencing_id, presence: true

  VALID_SEQUENCE_REGEX = /\A[AGCT]*\z/

  validates :mid, format:
      { with: VALID_SEQUENCE_REGEX, message: "must be a string of only A, C, G, and T" }

  validates :primer, presence: true, format:
    { with: VALID_SEQUENCE_REGEX, message: "must be a string of only A, C, G, and T" }
  validates :adapter, presence: true, format:
      { with: VALID_SEQUENCE_REGEX, message: "must be a string of only A, C, G, and T" }
  validates :breaksite, presence: true, format:
    { with: VALID_SEQUENCE_REGEX, message: "must be a string of only A, C, G, and T" }

  validates :brkchr, presence: true, inclusion: 
                  { in: ((1..22).to_a + ["X","Y"]).map { |a| a.to_s }, message: "not a valid chromosome name" }
  validates :brkstrand, presence: true, inclusion: { in: [true, false] }
  validates :brkstart, presence: true, numericality: { only_integer: true }
  validates :brkend, presence: true, numericality: { only_integer: true }

end
