class Chromosome < ActiveRecord::Base
  belongs_to :assembly

  validates :assembly_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :assembly_id }
  validates :size, presence: true,
                   numericality: { only_integer: true, greater_than: 0 }
end
