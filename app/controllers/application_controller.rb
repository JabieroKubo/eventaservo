# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Constants

  before_action :set_raven_context

  def user_is_owner_or_admin(event)
    user_signed_in? && (current_user.is_owner_of(event) || current_user.admin?)
  end
  helper_method :user_is_owner_or_admin

  private

    def set_raven_context
      Raven.user_context(id: session[:current_user_id]) # or anything else in session
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    end

    def authenticate_admin!
      redirect_to root_path unless current_user.admin?
    end
end
