class ApplicationController < ActionController::Base
  include Authentication
  include ActiveStorage::SetCurrent

  allow_browser versions: :modern
  before_action :set_layout

  def set_layout
    @layout = user_signed_in? ? "application" : "authentication"
  end
end
