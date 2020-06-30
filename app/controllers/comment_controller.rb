class CommentController < ApplicationController
  def index
    @comments = Comment.all
    @comments_tree = Comment.hash_tree(:limit_depth => 2)
    render({ :template => "comments/index.html.erb" })
  end

  def new
    @comment = Comment.new(parent_id: params[:parent_id])
    if params[:parent_id].present?
      @parent_id = params.fetch("parent_id")
    end
    render({ :template => "comments/new.html.erb" })
  end

  def create
    @comment = Comment.new
    @comment.title = params.fetch("title")
    @comment.users_id = params.fetch("user_id")
    @comment.body = params.fetch("body")
    if params[:parent_id].present?
      @comment.parent_id = params.fetch("parent_id")
    end

    if @comment.valid?
      @comment.save
      flash[:notice] = 'Your comment was successfully added!'
      redirect_to("/comments")
    else
      flash[:alert] = 'Your comment was NOT added!'
      redirect_to("/comments")
    end
  end
end