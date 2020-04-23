# frozen_string_literal: true

class CoursesController < ApplicationController
  respond_to :html, :json

  before_action :set_course, only: %i[show edit update sign_up]
  before_action :ensure_slot_allowed, only: %i[sign_up]

  def index
    @years   = []
    @months  = []
    @days    = []
    @courses = []

    @year = params[:year]
    @month = params[:month]
    @day = params[:day]

    courses = Course.all

    @lang_code = params[:language]
    if @lang_code.present?
      language = Language.find_by(code: @lang_code)
      courses = courses.with_language(language) unless language.nil?
    end

    @teacher_name = params[:teacher]
    if @teacher_name.present?
      teacher = Teacher.find_by(name: @teacher_name)
      courses = courses.with_teacher(teacher) unless teacher.nil?
    end

    courses = courses.available

    if @year
      if @month
        if @day
          @courses = Hash.new { |h, k| h[k] = [] }
          courses.on_day(@year.to_i, @month.to_i, @day.to_i).each do |course|
            @courses[course.time_slot.hour].push(course)
          end
        else
          @days = courses.days(@year.to_i, @month.to_i)
        end
      else
        @months = courses.months(@year.to_i)
      end
    else
      @years = courses.years
    end
  end

  def show
  end

  def create
    days = params[:days].split(',')
    hours = params[:hours]
    zoom_url = params[:zoom_url]

    no_error = true
    days.each do |day|
      next if day.blank?

      hours.each do |hour|
        next if hour.blank?

        time_slot = DateTime.parse("#{day} #{hour}")
        course = current_user.teacher_profile.courses.new(time_slot: time_slot, zoom_url: zoom_url)
        no_error &= course.save
      end
    end
    flash[:success] = 'Courses were successfully created.' if no_error
    redirect_back fallback_location: root_path
  end

  def edit
  end

  def update
    post_params = params.require(:course).permit(:zoom_url, :content, :feedback)
    if @course.update(post_params)
      flash[:success] = 'Course was successfully updated.'
      CourseMailer.notify_feedback_update(@course).deliver_later if course.feedback_changed?
    end
    redirect_back fallback_location: root_path
  end

  def sign_up
    Course.transaction do
      @course.student = current_user
      @course.language = Language.find(params[:language_id])
      @course.save

      current_user.use_ticket
    end

    CourseMailer.sign_up(@course).deliver_later
    CourseMailer.reservation(@course).deliver_later

    flash[:success] = "Signed up for a [#{@course.language.name}] course with [#{@course.teacher.user.username}] at [#{@course.time_slot}]." # rubocop:disable Layout/LineLength
    redirect_to courses_path
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def ensure_slot_allowed
    teacher_profile = current_user.teacher_profile
    return if teacher_profile.nil?

    if teacher_profile.id == @course.teacher.id
      flash[:info] = 'Unable to sign up for your own course.'
      redirect_back fallback_location: root_path && return
    end

    teaching_slot = teacher_profile.courses.where(time_slot: @course.time_slot)
    return if teaching_slot.empty?

    flash[:info] = 'Unable to sign up : You already have a teaching slot registered at the same time.'
    redirect_back fallback_location: root_path
  end
end
