class Library < ActiveRecord::Base

  belongs_to :researcher
  belongs_to :sequencing
  has_many :junctions, dependent: :destroy

  attr_accessor :junction_count

  before_validation do
    format_attributes
    
  end


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

  validates :cutter, format:
    { with: VALID_SEQUENCE_REGEX, message: "must be a string of only A, C, G, and T" }

  validates :assembly, presence: true, inclusion:
                  { in: ["mm9","hg19"], message: "must be one of 'mm9' or 'hg19'" }

  validates :brkstrand, presence: true, inclusion: { in: ["+", "-"],
                                          message: "must be either '+' or '-'" }
  validates :brkstart, presence: true, numericality: { only_integer: true, greater_than: 0,
                                        message: "must be an integer greater than 0" }
  validates :brkend, presence: true, numericality: { only_integer: true, greater_than: 0,
                                      message: "must be an integer greater than 0" }

  validate  :brksite_exists_in_assembly


  def self.to_txt(options = {})
    CSV.generate(options) do |txt|
      txt << %w[Id Library Sequencing Researcher Assembly]
      all.each do |library|
        txt << [library.id, library.name, library.sequencing.run, library.researcher.name, library.assembly]
      end
    end
  end

  def format_attributes

    mid.to_s.upcase!
    primer.to_s.upcase!
    adapter.to_s.upcase!
    breaksite.to_s.upcase!
    cutter.to_s.upcase!
    if brkchr.is_a?(Numeric)
      self.brkchr = brkchr.to_i.to_s
    elsif brkchr.is_a?(String)      
      self.brkchr = "chr"+brkchr unless brkchr[/chr(\w+)/i]
    end
    if brkstrand.is_a?(Numeric)
      self.brkstrand = "+" if brkstrand == 1
      self.brkstrand = "-" if brkstrand == -1
    elsif brkstrand.is_a?(String)
      self.brkstrand = "+" if brkstrand == "1"
      self.brkstrand = "-" if brkstrand == "-1"
    end
    self.brkstart = brkstart.to_i
    self.brkend = brkend.to_i

  end

  def brksite_exists_in_assembly
    unless Assembly.find_by(name: assembly).chromosomes.map{|c| c.name}.include?(brkchr)
      errors.add(:brkchr, "must exist in given assembly")
    else
      unless brkstart <= Assembly.find_by(name: assembly).chromosomes.find_by(name: brkchr).size
        errors.add(:brkstart, "must exist on given chromosome")
      end
      unless brkend <= Assembly.find_by(name: assembly).chromosomes.find_by(name: brkchr).size
        errors.add(:brkend, "must exist on given chromosome")
      end
    end
  end


end
