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

  validates :cutter, format:
    { with: VALID_SEQUENCE_REGEX, message: "must be a string of only A, C, G, and T" }

  validates :assembly, presence: true, inclusion:
                  { in: ["mm9","hg19"], message: "must be one of 'mm9' or 'hg19'" }

  validates :strand, presence: true, inclusion: { in: ["+", "-"],
                                          message: "must be either '+' or '-'" }
  validates :bstart, presence: true, numericality: { only_integer: true, greater_than: 0,
                                        message: "must be an integer greater than 0" }
  validates :bend, presence: true, numericality: { only_integer: true, greater_than: 0,
                                      message: "must be an integer greater than 0" }

  validate  :brksite_exists_in_assembly


  def self.to_txt(options = {})
    CSV.generate(options) do |txt|
      txt << %w[Library Sequencing Researcher Assembly Chr Start End Strand Breakseq Breaksite MID Primer Adapter Cutter Description]
      all.each do |exp|
        txt << [exp.name, exp.sequencing.run, exp.researcher.name, exp.assembly, exp.chr, exp.bstart, exp.bend, exp.strand, exp.breakseq, exp.breaksite, exp.mid, exp.primer, exp.adapter, exp.cutter, exp.description]
      end
    end
  end

  def format_attributes

    mid.to_s.upcase!
    primer.to_s.upcase!
    adapter.to_s.upcase!
    breakseq.to_s.upcase!
    cutter.to_s.upcase!
    if chr.is_a?(Numeric)
      self.chr = chr.to_i.to_s
    elsif chr.is_a?(String)      
      self.chr = "chr"+chr unless chr[/chr(\w+)/i]
    end
    if strand.is_a?(Numeric)
      self.strand = "+" if strand == 1
      self.strand = "-" if strand == -1
    elsif strand.is_a?(String)
      self.strand = "+" if strand == "1"
      self.strand = "-" if strand == "-1"
    end
    self.bstart = bstart.to_i
    self.bend = bend.to_i

  end

  def brksite_exists_in_assembly
    unless Assembly.find_by(name: assembly).chromosomes.map{|c| c.name}.include?(chr)
      errors.add(:chr, "must exist in given assembly")
    else
      unless bstart <= Assembly.find_by(name: assembly).chromosomes.find_by(name: chr).size
        errors.add(:bstart, "must exist on given chromosome")
      end
      unless bend <= Assembly.find_by(name: assembly).chromosomes.find_by(name: chr).size
        errors.add(:bend, "must exist on given chromosome")
      end
    end
  end


end
