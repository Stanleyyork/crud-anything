class UsersController < ApplicationController
  
  before_filter :authorize, except: [:new, :create]
  before_filter :current_user_logged_in, except: [:index, :show, :edit, :show_user_cards, :show_user_search_queries, :show_user_search_query]

  def index
    @users = User.all
  end

  def new
    
  end

  def create
    user = User.new(user_params)
    if user.save
      session[:user_id] = user.id
      redirect_to '/'
    else
      flash[:error] = user.errors.full_messages.join(", ")
      redirect_to '/signup'
    end
  end

  def show
    @user = User.find(params[:id])
    @searchQueries = SearchQuery.where(user_id: @user.id)
    @cards = Card.where(user_id: @user.id)
  end

  def show_user_cards
    @user = User.find(params[:id])
    @card_groupings = Card.where(user_id: @user.id).group_by {|c| c.searchQueryString}
  end

  def show_user_search_queries
    @user = User.find(params[:id])
    @searchQueries = SearchQuery.where(user_id: @user.id)
    @cards = Card.where(user_id: @user.id)
  end

  def show_user_search_query
    @searchQuery = SearchQuery.find(params[:id])
    @user_id = @searchQuery.user_id
    @cards = Card.where(user_id: @user_id)
    @cards_for_chart = Card.where(user_id: @user_id).group(:price).count(:id)
    cards_chart_array = []
    @cards_for_chart.each do |x|
      cards_chart_array.push([x[0],x[1]])
    end

    data_table = GoogleVisualr::DataTable.new

    # Add Column Headers
    data_table.new_column('number', 'Count' )
    data_table.new_column('number', 'Price')

    # Add Rows and Values
    # data_table.add_rows([
    #     [1000, 400],
    #     [1170, 460],
    #     [660, 1120],
    #     [1030, 540]
    # ])
    data_table.add_rows(cards_chart_array)

    option = { width: 400, height: 240, title: 'title' }
    @cards_chart = GoogleVisualr::Interactive::AreaChart.new(data_table, option)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    user_params = params.require(:user).permit(:name, :email, :password)
    if @user.update_attributes(user_params)
      redirect_to user_path(@user)
    else
      flash[:error] = @user.errors.full_messages.join(", ")
      redirect_to edit_user_path
    end
  end

  def destroy
    @user = current_user
    if @user.destroy
        redirect_to signup_path, notice: "User deleted."
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

end
