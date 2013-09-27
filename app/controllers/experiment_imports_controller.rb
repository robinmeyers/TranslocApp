class ExperimentImportsController < ApplicationController



  def create
    @sequencing = Sequencing.find(params[:experiment_import][:sequencing_id])
    @experiment_import = ExperimentImport.new(params[:experiment_import])
    @experiment_import.researcher_id = current_researcher.id
    if @experiment_import.file.present? && @experiment_import.save
      flash[:success] = "All experiments successfully imported!"
      redirect_to sequencing_path(@sequencing)
    else
      @experiment_import.errors.add(:file, "must be selected") unless @experiment_import.file.present?
      @experiment = @sequencing.experiments.build
      render 'experiments/new'
    end
  end

end
