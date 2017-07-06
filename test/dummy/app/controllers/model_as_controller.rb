class ModelAsController < ApplicationController
  before_action :set_model_a, only: [:show, :edit, :update, :destroy]

  # GET /model_as
  def index
    @model_as = ModelA.all
  end

  # GET /model_as/1
  def show
  end

  # GET /model_as/new
  def new
    @model_a = ModelA.new
  end

  # GET /model_as/1/edit
  def edit
  end

  # POST /model_as
  def create
    @model_a = ModelA.new(model_a_params)

    if @model_a.save
      redirect_to @model_a, notice: 'Model a was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /model_as/1
  def update
    if @model_a.update(model_a_params)
      redirect_to @model_a, notice: 'Model a was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /model_as/1
  def destroy
    @model_a.destroy
    redirect_to model_as_url, notice: 'Model a was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_model_a
      @model_a = ModelA.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def model_a_params
      params.require(:model_a).permit(:image, :images)
    end
end
