# frozen_string_literal: true

class TeachersController < ApplicationController
  respond_to :html, :json

  before_action :set_teacher, only: %i[show edit update]

  def show
    @course = Course.new
  end

  def new
    @teacher = Teacher.new
    authorize @teacher
  end

  def create
    @teacher = current_user.new(post_params)
    authorize @teacher
    flash[:success] = 'Teacher profile was successfully created.' if @teacher.save
    respond_with @teacher
  end

  def edit
    authorize @teacher
  end

  def update
    authorize @teacher
    flash[:success] = 'Teacher profile was successfully updated.' if @teacher.update(post_params)
    respond_with @teacher
  end

  def add_language
    authorize Teacher
    user_id = params[:user]
    language_id = params[:language]
    user = User.find(user_id)
    if user.teacher_profile.nil?
      user.teacher_profile = Teacher.new(user: user, name: user.username, presentation: 'Present yourself here...')
      user.save
    end
    teacher = user.teacher_profile
    language = Language.find(language_id)
    teached_language = TeachedLanguage.find_by(teacher: teacher, language: language)
    if teached_language.nil?
      teached_language = TeachedLanguage.new(teacher: teacher, language: language)
      flash[:success] = "Language #{language.name} added to teacher #{teacher.name}." if teached_language.save
    else
      flash[:info] = "Language #{teached_language.language.name} already available for teacher #{teached_language.teacher.name}." # rubocop:disable Layout/LineLength
    end
    redirect_back fallback_location: root_path
  end

  def action_required_courses
    order = params[:order] == 'asc' ? :asc : :desc
    @courses = current_user.teacher_profile.courses
                           .action_required
                           .order(time_slot: order)
  end

  def future_courses
    order = params[:order] == 'asc' ? :asc : :desc
    @courses = current_user.teacher_profile.courses.future.order(time_slot: order)
  end

  private

  def post_params
    params.require(:teacher).permit(:language_id, :name, :presentation, :image, :image_cache)
  end

  def set_teacher
    @teacher = Teacher.find(params[:id])
  end
end
