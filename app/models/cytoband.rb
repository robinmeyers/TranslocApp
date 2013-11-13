class Cytoband < ActiveRecord::Base
  belongs_to :assembly

  validates :assembly_id, presence: true
  validates :name, presence: true,
                    uniqueness: { scope: [:assembly_id,:chrom] }
  validates :stain, presence: true
  validates :start, presence: true
  validates :end, presence: true
end
