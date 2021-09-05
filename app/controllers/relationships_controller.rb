class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find_by id: params[:followed_id]
    current_user.follow @user
    format_html_js
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow @user
    format_html_js
  end

  def format_html_js
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end
end
