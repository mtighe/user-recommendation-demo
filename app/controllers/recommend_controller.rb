class RecommendController < ApplicationController

  def index
    @username = params["username"]
    engine_ip = params["engine_ip"]
    @recommendation_type = params[:recommendation_type]
    @recommendation_type ||= "similar"

    unless @username.nil?
      usernames = @username.split(',')

      @users = []
      usernames.each do |username|
        # fetch user from 500px
        user_params = {
          username: username
        }

        userResponse = JSON.parse(F00px.get("users/show?#{user_params.to_query}").body)["user"]

        if userResponse.nil?
          puts "Could not find user #{username}!"
        else
          user = {
            id: userResponse["id"],
            fullname: userResponse["fullname"],
            avatar: userResponse["avatars"]["large"]["https"],
            path: "https://500px.com/#{userResponse['username']}"
          }
          @users << user
        end
      end

      users_for_rec = nil
      if @recommendation_type == "for_user"
        # fetch users friends, recommend based on them

        # TODO loop to get all pages
        page = 1

        friends_params = {
          rpp: 100,
          page: page
        }
        friendsResponse = JSON.parse(F00px.get("users/#{@users[0][:id]}/friends?#{friends_params.to_query}").body)

        users_for_rec = friendsResponse["friends"].map { |friend| friend["id"] }
        users_for_rec.flatten!
      else
        # "similar"
        # recommend similar to this user
        users_for_rec = [@users.map { |u| u[:id] }]
        users_for_rec.flatten!
      end

      user_ids = get_recommendation(users_for_rec)
    else
      # default when not recommending
      user_ids = [1, 126704]
    end

    @users = get_users(user_ids)
  end

  private

  def get_recommendation(ids)
    client = PredictionIO::EngineClient.new(ENV['PIO_ENGINE_URL'])
    response = client.send_query(items: ids, num: 100)["itemScores"]

    users = response.map { |item| item["item"].to_i }
    users
  end

  def get_users(ids)
    user_params = {
      ids: ids,
      respond_with: "array"
    }
    usersResponse = JSON.parse(F00px.get("users?#{user_params.to_query}").body)["users"]
    users = usersResponse.map do |user|
      {
        id: user["id"],
        avatar: user["avatars"]["large"]["https"],
        fullname: user["fullname"],
        path: "https://500px.com/#{user['username']}"
      }
    end

    users.each do |user|
      photo_params = {
        feature: "user",
        user_id: user[:id],
        rpp: 10,
        image_size: 32
      }
      photosResponse = JSON.parse(F00px.get("photos?#{photo_params.to_query}").body)["photos"]
      user[:photos] = photosResponse.map do |photo|
        {
          link: "https://500px.com#{photo['url']}",
          img: photo['image_url']
        }
      end
    end

    users
  end

end
