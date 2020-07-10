# frozen_string_literal: true

class TeachersController < ApplicationController
  respond_to :html, :json

  before_action :set_teacher, only: %i[show edit update]

  def show
    @course = Course.new
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
    teacher = user.ensure_teacher_profile
    flash.merge!(teacher.add_language(language_id))
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
