class StaticPagesController < ApplicationController
  before_filter :set_angular_app_name, except: [:index]
  before_filter :gather_public_method_names, only: [:index]

  def index
    @angular_app_name = ""
  end

  # AngularJS actions

  private 
  
  def set_angular_app_name
    @angular_app_name = "#{action_name}App"
  end

  def gather_public_method_names
    @public_methods = StaticPagesController.action_methods - ["index"]
  end
end

