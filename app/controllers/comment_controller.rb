class CommentController < ApplicationController
  def index
    @comments = Comment.all
    render({ :template => "comments/index.html.erb" })
  end

  def new
    @comment = Comment.new
    render({ :template => "comments/new.html.erb" })
  end

  def create
    @comment = Comment.new
    @comment.title = params.fetch("title")
    @comment.users_id = params.fetch("user_id")
    @comment.body = params.fetch("body")

    if @comment.valid?
      @comment.save
      flash[:notice] = 'Your comment was successfully added!'
      redirect_to("/comments")
    else
      flash[:alert] = 'Your comment was NOT added!'
      redirect_to("/comments/new")
    end
  end
end