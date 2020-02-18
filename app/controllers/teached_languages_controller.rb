class TeachedLanguagesController < ApplicationController
  def activate
    authorize TeachedLanguage
    change_active_state true
    redirect_to admin_index_path
  end

  def deactivate
    authorize TeachedLanguage
    change_active_state false
    redirect_to admin_index_path
  end

  private
  def change_active_state(new_active_state)
    teached_language = TeachedLanguage.find(params[:id])
    teached_language.update_attribute(:active, new_active_state)
  end
end
