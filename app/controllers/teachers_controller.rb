class TeachersController < ApplicationController
  before_action :get_current_user_teacher_profile, only: [:index, :show, :edit, :update]
  respond_to :html, :json

  def new
    @teacher = Teacher.new
  end

  def create
    @teacher = current_user.new(post_params)
    flash[:success] = 'Teacher profile was successfully created.' if @teacher.save
    respond_with @teacher
  end

  def update
    logger.debug @teacher
    logger.debug post_params
    flash[:success] = 'Post was successfully updated.' if @teacher.update(post_params)
    respond_with @teacher
  end

  private
  def get_current_user_teacher_profile
    @teacher = current_user.teacher_profile
  end

  def post_params
    params.require(:teacher).permit(:language_id, :presentation, :image, :image_cache)
  end
end
