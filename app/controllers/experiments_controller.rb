class ExperimentsController < ApplicationController
  before_action :signed_in_researcher

  def new
    @sequencing ||= Sequencing.find(params[:sequencing_id])
    @experiment = @sequencing.experiments.build
    @experiment_import = ExperimentImport.new()
  end

  # def create
  #   @experiment = current_researcher.experiments.build(experiment_params)
  #   if @experiment.save
  #     flash[:success] = "Experiment created!"
  #     redirect_to sequencing_path(@experiment.sequencing)
  #   else
  #     @new_experiment = @experiment
  #     @sequencing = Sequencing.find(params[:experiment][:sequencing_id])
  #     render 'sequencings/show'

  #   end
  # end

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


  def destroy
  end

  private

    def experiment_params
      params.require(:experiment).permit(:name, 
        :assembly, :brkchr, :brkstart, :brkend, :brkstrand, :mid, :primer,
        :adapter, :breaksite, :cutter, :description)
    end
end