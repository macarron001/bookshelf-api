class Api::UserBooksController < ApplicationController
  before_action :authenticate_user!
  before_action :get_user_book, only: [:destroy, :update, :show]

  def index
    books = params[:finish_date] == nil ? UserBook.to_read(current_user) : UserBook.finished(current_user)
    if books.empty?
      render json: "List is empty", status: unprocessable_entity
    else
      render json: books
    end
  end

  def show
    render json: @user_book
  end

  def create
    user_book = UserBook.create(user_book_params)
    if user_book.save
      render json: {
        status: 201,
        message: 'Successfully created!',
        user_book: user_book,
      }
    else
      render json: user_book.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    if @user_book.destroy!

      render json: {
        status: 200,
        message: 'Successfully removed!',
        user_book: @user_book,
      }
    else
      render json: @user_book.errors.full_messages, status: :unprocessable_entity
    end
  end


  def update
    if @user_book.update(user_book_params)
      render json: {
        status: 200,
        message: 'Successfully updated!',
        user_book: @user_book,
      }
    else
      render json: @user_book.errors.full_messages, status: :unprocessable_entity
    end
  end
  
  private
  
  def get_user_book
    @user_book = UserBook.find(params[:id])
  end

  def user_book_params 
    params.require(:user_book).permit(:user_id, :book_id, :rating, :notes, :start_date, :finish_date)
  end
end