class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :ensure_admin_exist
  layout :layout_by_resource
  before_action :set_locale
  before_action :authenticate_student!
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def set_locale
    I18n.locale = current_student.try(:locale) || ( params[:locale] || I18n.default_locale )
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def configure_permitted_parameters

    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :nickname, :avatar, :avatar_cache, :remove_avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :bio, :id_number, :locale, :nickname, :avatar, :avatar_cache, :remove_avatar ])

  end

  def after_sign_in_path_for(resource)

    if resource == current_admin_user
      admin_root_path
    else
      announcements_path
    end
  end

  def layout_by_resource
    if devise_controller? && resource_name == :admin_user
      "admin/log_form"
    else
      "application"
    end
  end

  def ensure_admin_exist
    flash.clear
    if session[:admin_present].nil? && AdminUser.none?
      redirect_to setup_admin_path
    else
      session[:admin_present] = true
    end
  end

end
