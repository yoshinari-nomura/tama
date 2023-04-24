class WorkHoursController < ApplicationController
  before_action :set_work_hour, only: %i[ show edit update destroy ]

  # GET /work_hours or /work_hours.json
  def index
    @work_hours = WorkHour.all
  end

  # GET /work_hours/1 or /work_hours/1.json
  def show
  end

  # GET /work_hours/new
  def new
    @work_hour = WorkHour.new
  end

  # GET /work_hours/1/edit
  def edit
  end

  # POST /work_hours or /work_hours.json
  def create
    @work_hour = WorkHour.new(work_hour_params)

    respond_to do |format|
      if @work_hour.save
        format.html { redirect_to work_hour_url(@work_hour), notice: "Work hour was successfully created." }
        format.json { render :show, status: :created, location: @work_hour }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @work_hour.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /work_hours/1 or /work_hours/1.json
  def update
    respond_to do |format|
      if @work_hour.update(work_hour_params)
        format.html { redirect_to work_hour_url(@work_hour), notice: "Work hour was successfully updated." }
        format.json { render :show, status: :ok, location: @work_hour }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @work_hour.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_hours/1 or /work_hours/1.json
  def destroy
    @work_hour.destroy

    respond_to do |format|
      format.html { redirect_to work_hours_url, notice: "Work hour was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work_hour
      @work_hour = WorkHour.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def work_hour_params
      params.require(:work_hour).permit(:dtstart, :dtend, :actual_working_minutes, :assignment_id)
    end
end