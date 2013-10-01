class ExperimentsController < ApplicationController
  before_action :signed_in_researcher
  before_action :correct_researcher_or_admin, only: [:edit, :update, :destroy]

  def new
    @sequencing ||= Sequencing.find(params[:sequencing_id])
    @experiment = @sequencing.experiments.build
    @experiment_import = ExperimentImport.new()
  end

 

  def create
    @experiment = current_researcher.experiments.build(experiment_params)
    @sequencing = Sequencing.find(params[:experiment][:sequencing_id])
    @experiment.sequencing = @sequencing
    if @experiment.save
      flash[:success] = @experiment.name + " was successfully created!"
      redirect_to sequencing_path(@experiment.sequencing)
    else
      @experiment_import = ExperimentImport.new()
      render 'new'
    end
  end


  def edit
  end

  def update
    if @experiment.update_attributes(experiment_params)
      flash[:success] = "Experiment metadata updated!"
      redirect_to @experiment.sequencing
    else
      render 'edit'
    end
  end

  def destroy

  end

  private

    def experiment_params
      params.require(:experiment).permit(:name, 
        :assembly, :brkchr, :brkstart, :brkend, :brkstrand, :mid, :primer,
        :adapter, :breaksite, :cutter, :description)
    end

    def correct_researcher_or_admin
      @experiment = Experiment.find(params[:id])
      redirect_to(root_url) unless current_researcher?(@experiment.researcher) ||
                                      current_researcher.admin?
    end
end