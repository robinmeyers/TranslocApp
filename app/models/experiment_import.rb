class ExperimentImport
  include ActiveModel::Model

  attr_accessor :file, :sequencing_id, :researcher_id

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_experiments.map(&:valid?).all?
      imported_experiments.each(&:save!)
      true
    else
      imported_experiments.each_with_index do |experiment, index|
        experiment.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_experiments
    @imported_experiments ||= load_imported_experiments
  end

  def load_imported_experiments
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1).map(&:downcase).map(&:to_sym)
    (2..spreadsheet.last_row).map do |i|
      importparams = ActionController::Parameters.new({
              experiment: Hash[[header, spreadsheet.row(i)].transpose]
            })

      # experiment = Experiment.find_by(id: params[:experiment][:id]) || Researcher.find(researcher_id).experiments.build(experiment_params)
      experiment = Researcher.find(researcher_id).experiments.build(experiment_import_params(importparams))
      experiment.sequencing = Sequencing.find(sequencing_id)
      Rails.logger.debug "imported experiment: #{experiment.attributes.inspect}"

      experiment
    end
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".txt" then Roo::CSV.new(file.path, col_sep: "\t", file_warning: :ignore)
    when ".xls" then Roo::Excel.new(file.path, file_warning: :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, file_warning: :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  private

    def experiment_import_params(importparams) 
      importparams.require(:experiment).permit(:name, 
        :assembly, :brkchr, :brkstart, :brkend, :brkstrand, :mid, :primer,
        :adapter, :breaksite, :cutter, :description)
    end


end
