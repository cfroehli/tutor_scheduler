# frozen_string_literal: true

class CoursesController < ApplicationController
  respond_to :html, :json

  before_action :set_course, only: %i[show edit update sign_up]
  before_action :ensure_slot_allowed, only: %i[sign_up]
  before_action :ensure_has_tickets, only: %i[sign_up]

  def index
    @year = params[:year].to_i
    @month = params[:month].to_i
    @day = params[:day].to_i
    setup_course_selector
  end

  def show
  end

  def create
    days = params[:days].split(',').reject(&:blank?)
    hours = params[:hours].reject(&:blank?).map(&:to_i).reject { |hour| hour < 7 || hour > 22 }
    zoom_url = params[:zoom_url]

    no_error = true
    days.each do |day|
      hours.each do |hour|
        time_slot = DateTime.parse("#{day} #{hour}")
        no_error &= current_user.teacher_profile.courses.create(time_slot: time_slot, zoom_url: zoom_url)
      end
    end

    flash[:success] = 'Courses were successfully created.' if no_error
    redirect_back fallback_location: root_path
  end

  def edit
  end

  def update
    post_params = params.require(:course).permit(:zoom_url, :content, :feedback)
    flash[:success] = 'Course was successfully updated.' if @course.update(post_params)
    redirect_back fallback_location: root_path
  end

  def sign_up
    if @course.sign_up(current_user, params[:language_id])
      flash[:success] = "Signed up for a [#{@course.language.name}] course with [#{@course.teacher.name}] at [#{@course.time_slot.in_time_zone}]."
    end
    redirect_to courses_path
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def ensure_slot_allowed
    teacher_profile = current_user.teacher_profile
    return unless teacher_profile

    if teacher_profile.id == @course.teacher.id
      flash[:info] = 'Unable to sign up for your own course.'
    else
      teaching_slot = teacher_profile.courses.where(time_slot: @course.time_slot)
      return if teaching_slot.empty?

      flash[:info] = 'Unable to sign up : You already have a teaching slot registered at the same time.'
    end
    redirect_back fallback_location: root_path
  end

  def ensure_has_tickets
    return if current_user.remaining_tickets.positive?

    flash[:danger] = 'You need a ticket to reserve a course.'
    redirect_back fallback_location: root_path
  end

  def courses
    @courses ||= build_available_courses_set
  end

  def build_available_courses_set
    courses_set = Course.all
    courses_set = filter_by_language(courses_set)
    courses_set = filter_by_teacher(courses_set)
    courses_set.available
  end

  def filter_by_language(filtered_courses)
    @lang_code = params[:language]
    if @lang_code.present?
      language = Language.find_by(code: @lang_code)
      filtered_courses = filtered_courses.with_language(language) if language
    end
    filtered_courses
  end

  def filter_by_teacher(filtered_courses)
    @teacher_name = params[:teacher]
    if @teacher_name.present?
      teacher = Teacher.find_by(name: @teacher_name)
      filtered_courses = filtered_courses.with_teacher(teacher) if teacher
    end
    filtered_courses
  end

  def setup_course_daily_schedule
    @courses_schedule = Hash.new { |hash, key| hash[key] = [] }
    courses.on_day(@year, @month, @day).each do |course|
      @courses_schedule[course.time_slot.hour].push(course)
    end
  end

  def setup_course_day_selector
    if @day.positive?
      setup_course_daily_schedule
    else
      @days = courses.days(@year, @month)
    end
  end

  def setup_course_month_selector
    if @month.positive?
      setup_course_day_selector
    else
      @months = courses.months(@year)
    end
  end

  def setup_course_selector
    @years   = []
    @months  = []
    @days    = []
    if @year.positive?
      setup_course_month_selector
    else
      @years = courses.years
    end
  end
end
