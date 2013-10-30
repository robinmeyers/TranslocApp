class LibraryImport
  include ActiveModel::Model

  attr_accessor :file, :sequencing_id, :researcher_id

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_libraries.map(&:valid?).all?
      imported_libraries.each(&:save!)
      true
    else
      imported_libraries.each_with_index do |library, index|
        library.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_libraries
    @imported_libraries ||= load_imported_libraries
  end

  def load_imported_libraries
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1).map(&:downcase).map(&:to_sym)
    (2..spreadsheet.last_row).map do |i|
      importparams = ActionController::Parameters.new({
              library: Hash[[header, spreadsheet.row(i)].transpose]
            })

      # library = Library.find_by(id: params[:library][:id]) || Researcher.find(researcher_id).libraries.build(library_params)
      library = Researcher.find(researcher_id).libraries.build(library_import_params(importparams))
      library.sequencing = Sequencing.find(sequencing_id)
      Rails.logger.debug "imported library: #{library.attributes.inspect}"

      library
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

    def library_import_params(importparams) 
      importparams.require(:library).permit(:name, 
        :assembly, :brkchr, :brkstart, :brkend, :brkstrand, :mid, :primer,
        :adapter, :breaksite, :cutter, :description)
    end


end
