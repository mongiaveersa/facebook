class RequestmailJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform(c_user,user)
    
    if !c_user.friends.include?(user)
      ActionMailer::Base.mail(
        from: "confirmation@example.com", 
        to: user.email, 
        subject: "New request", 
        body: "You have recieved a new friend request." 
      ).deliver_now
    end
  end
end
