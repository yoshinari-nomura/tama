class WorkHoursController < ApplicationController
  before_action :set_work_hour, only: %i[ show edit update destroy ]
  before_action :set_course, only: %i[ new create ]
  before_action :set_assignments, only: %i[ create update ]

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
    ActiveRecord::Base.transaction do
      if @assignments.nil? || @assignments.empty?
        puts "++++++++++++++++++++++++++++ WorkHour single creation"
        @work_hour = if work_hour_params then WorkHour.new(work_hour_params) else @work_hour_template.dup.slide(7) end
        @work_hour.save!
      else
        puts "---------------------------- WorkHour multiple creation"
        @assignments.each do |assignment|
          @work_hour = if work_hour_params then WorkHour.new(work_hour_params) else @work_hour_template.dup.slide(7) end
          @work_hour.assignment_id = assignment.id
          @work_hour.save!
        end
      end
      respond_to do |format|
        format.html { redirect_to work_hour_url(@work_hour), notice: "Work hour was successfully created." }
        format.json { render :show, status: :created, location: @work_hour }

        # pass notice to create.turbo_stream.erb
        flash.now.notice = "Work hours was successfully created."
        format.turbo_stream {} # will be rendered by create.turbo_stream.erb
      end
    rescue => e
      puts "************************** Error #{e} *********************"
      respond_to do |format|
        @work_hour ||= WorkHour.new
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @work_hour.errors, status: :unprocessable_entity }

        # In case error, we do not return turbo stream.
        # HTML render new (_form) will work.
        # Validation will be shown inline, no need to use flash.
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
    if params[:with_colleagues]
      @work_hours = @work_hour.colleagues.to_a
      @work_hour.colleagues.destroy_all
      pp @work_hours
    else
      @work_hour.destroy
    end

    respond_to do |format|
      format.html { redirect_to work_hours_url, notice: "Work hour was successfully destroyed." }
      format.json { head :no_content }

      # pass notice to destroy.turbo_stream.erb
      flash.now.notice = "Work hour was successfully destroyed."
      format.turbo_stream {} # will be rendered by destroy.turbo_stream.erb
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work_hour
      @work_hour = WorkHour.find(params[:id])
      @course = @work_hour.course
    end

    def set_course
      puts "--------------------------course: #{@course}"
      @course = Course.find(params[:course_id])
    end

    def set_assignments
      # set @assignments for bulk insert in create/update action

      @assignments = nil
      pwh = params[:work_hour]

      if pwh && pwh[:assignment_id].respond_to?(:first)
        @assignments = Assignment.where(id: pwh[:assignment_id])
        params[:work_hour][:assignment_id] = nil

      elsif params[:with_colleagues] && params[:template]
        @work_hour_template = WorkHour.find(params[:template])
        @assignments = @work_hour_template.colleagues.map(&:assignment)
      end
    end

    # Only allow a list of trusted parameters through.
    def work_hour_params
      if @work_hour_template && params[:work_hour].nil?
        nil
      else
        params.require(:work_hour).permit(:dtstart, :dtend, :actual_working_minutes, :assignment_id)
      end
    end
end
