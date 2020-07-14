class UserController < ApplicationController
  #search users
  def search_users
    render json: User.search(params[:query], {
      fields: ["username"],
      match: :word_start,
      limit: 10,
      load: false,
      misspellings: {below: 5}
    }).map(&:username)
  end
end



    