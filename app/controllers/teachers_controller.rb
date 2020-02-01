class TeachersController < ApplicationController
  respond_to :html, :json

  def show
    @teacher = find_teacher
    @course = Course.new
  end

  def new
    @teacher = Teacher.new
  end

  def create
    @teacher = current_user.new(post_params)
    flash[:success] = 'Teacher profile was successfully created.' if @teacher.save
    respond_with @teacher
  end

  def edit
    @teacher = find_teacher
    authorize @teacher
  end

  def update
    @teacher = find_teacher
    authorize @teacher
    flash[:success] = 'Teacher profile was successfully updated.' if @teacher.update(post_params)
    respond_with @teacher
  end

  def add_language
    authorize Teacher
    user_id, language_id = params[:user], params[:language]
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
      flash[:info] = "Language #{teached_language.language.name} already available for teacher #{teached_language.teacher.name}."
    end
    redirect_to users_path
  end

  private
  def post_params
    params.require(:teacher).permit(:language_id, :name, :presentation, :image, :image_cache)
  end

  def find_teacher
    Teacher.find(params[:id])
  end
end
