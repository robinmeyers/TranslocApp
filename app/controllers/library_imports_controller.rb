class LibraryImportsController < ApplicationController



  def create
    @sequencing = Sequencing.find(params[:library_import][:sequencing_id])
    @library_import = LibraryImport.new(params[:library_import])
    @library_import.researcher_id = current_researcher.id
    if @library_import.file.present? && @library_import.save
      flash[:success] = "All libraries successfully imported!"
      redirect_to sequencing_path(@sequencing)
    else
      @library_import.errors.add(:file, "must be selected") unless @library_import.file.present?
      @library = @sequencing.libraries.build
      render 'libraries/new'
    end
  end

end
