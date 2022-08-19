require 'rails_helper'

RSpec.describe "ListItems", type: :request do
  context 'success cases' do
    before do
      @user = FactoryBot.create(:user)
      sign_in(@user)
  
      @book = FactoryBot.create(:book)
      @book1 = FactoryBot.create(:book)
      @book2 = FactoryBot.create(:book)
  
      @list1 = ListItem.create(user_id: @user.id, book_id: @book1.id)
      @list2 = ListItem.create(user_id: @user.id, book_id: @book2.id, start_date: Time.now, finish_date: Time.now)
    end
  
    it 'returns all list items' do
      get '/list_items'
      json = JSON.parse(response.body)
  
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response).to have_http_status(:success)
      expect(json.length).to eq(2)
    end
  
    it 'returns a specific list_item' do
      get "/list_items/#{@list2.id}"
      json = JSON.parse(response.body)
  
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response).to have_http_status(:success)
      expect(Date.parse(json['start_date'])).to eq(@list2.start_date)
      expect(json['rating']).to eq(@list2.rating)
    end
  
    it 'creates a list item' do
      post '/list_items', params: { list_item: { 
        user_id: @user.id,
        book_id: @book.id
       } }
  
      json = JSON.parse(response.body)
  
      expect(json["status"]).to eq(201)
      expect(json["message"]).to eq('Successfully created!')
    end
  
    it 'removes a list item' do
      delete "/list_items/#{@list1.id}"
  
      json = JSON.parse(response.body)
      expect(json["status"]).to eq(200)
      expect(json["message"]).to eq('Successfully removed!')
    end
  
    it 'marks a list item as read' do
      patch "/list_items/#{@list2.id}", params: { list_item: { finish_date: Time.now } }
  
      json = JSON.parse(response.body)
      expect(json["status"]).to eq(200)
      expect(json["message"]).to eq('Successfully updated!')
    end
  
    it 'marks a list item as unread' do
      patch "/list_items/#{@list2.id}", params: { list_item: { finish_date: nil } }
  
      json = JSON.parse(response.body)
      expect(json["status"]).to eq(200)
      expect(json["message"]).to eq('Successfully updated!')
    end
  
    it 'updates the rating of a list item' do
      patch "/list_items/#{@list1.id}", params: { list_item: { rating: 2 } }
  
      json = JSON.parse(response.body)
      
      expect(json["status"]).to eq(200)
      expect(json["message"]).to eq('Successfully updated!')
      expect(json['list_item']['rating']).to eq(2)
    end
  
    it 'updates the notes of a list item' do
      patch "/list_items/#{@list1.id}", params: { list_item: { notes: "This is a good read" } }
  
      json = JSON.parse(response.body)
      expect(json["status"]).to eq(200)
      expect(json["message"]).to eq('Successfully updated!')
      expect(json['list_item']['notes']).to eq("This is a good read")
    end
  
    it 'shows all books marked to be read' do
      get "/to_read"
      json = JSON.parse(response.body)
  
      expect(json["status"]).to eq(200)
      expect(json["user"]["id"]).to eq(@user.id)
      expect(json["list"][0]["book_id"]).to eq(@book1.id)
    end
  
    it 'shows all books marked as finshed' do
      get "/finished"
      json = JSON.parse(response.body)
  
      expect(json["status"]).to eq(200)
      expect(json["user"]["id"]).to eq(@user.id)
      expect(json["list"][0]["book_id"]).to eq(@book2.id)
    end
  end

  context 'fail cases' do
    before do
      @book_less_user = FactoryBot.create(:user)
      sign_in @book_less_user

      @book = FactoryBot.create(:book)
      @item = FactoryBot.create(:list_item)
    end

    
    it 'will notify if reading list is empty' do
      get "/to_read"
      json = JSON.parse(response.body)

      expect(json["status"]).to eq(404)
      expect(json["message"]).to eq('The reading list is still empty')
    end
  
    it 'will notify if finished list is empty' do
      get "/finished"
      json = JSON.parse(response.body)
  
      expect(json["status"]).to eq(404)
      expect(json["message"]).to eq("You haven't finished any books yet")
    end

    it 'will not create if user already has the book' do
      ListItem.create(user_id: @book_less_user.id, book_id: @book.id)

      post '/list_items', params: { list_item: { 
        user_id: @book_less_user.id,
        book_id: @book.id
       } }
       json = JSON.parse(response.body)

       expect(response).to have_http_status(:unprocessable_entity)
       expect(json[0]).to eq("Book has already been taken")
    end

    it 'will not update with incorrect rating value' do
      patch "/list_items/#{@item.id}", params: { list_item: { rating: 6 } }
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[0]).to eq("Rating is not included in the list")
    end
  end
end
