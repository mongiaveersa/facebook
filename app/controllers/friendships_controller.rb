class FriendshipsController < ApplicationController
    before_action :authenticate_user!
    before_action :find_friendship, only: %i[destroy update]
  
    def create
      friendship = current_user.friendships.build(friendship_params)
      return unless friendship.save
  
      flash[:success] = 'Friend request sent'
      # Change the timing to your own accord to check when we have to send the notification mail 
      RequestmailJob.set(wait: 5.second).perform_later(current_user,User.find_by(id: friendship_params[:friend_id]))
      redirect_to request.referer || root_path
    end
  
    def destroy
      @friendship&.destroy_friendship
      redirect_to request.referer || root_path
    end
  
    def update
      return unless @friendship.confirm_friend
  
      flash[:success] = 'Friend request accepted'
      redirect_to request.referer || root_path
    end
  
    def pending
      @pending = current_user.pending_friends
    end
  
    def index
      @friendships=Friendship.all
     end
  
    private
  
    def find_friendship
      @friendship = Friendship.find_by(id: params[:id])
    end
  
    def friendship_params
      params.require(:friendship).permit(:friend_id)
    end
  end