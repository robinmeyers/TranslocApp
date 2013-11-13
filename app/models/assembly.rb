class Assembly < ActiveRecord::Base

  has_many :chromosomes, dependent: :destroy
  has_many :cytobands, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

end
