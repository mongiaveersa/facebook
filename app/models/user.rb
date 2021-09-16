class User < ApplicationRecord

  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,:confirmable, authentication_keys: [:login]

  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true
  # avatar
  has_one_attached :avatar
  validate :validate_username

  #friendship

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end

  attr_writer :login

  def login
    @login || username || email
  end


  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end


  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes_given, foreign_key: :user_id, class_name: 'Like',
                         dependent: :destroy, inverse_of: 'user'

  has_many :friendships, dependent: :destroy
  has_many :friends, -> { where('confirmed = ?', true) }, through: :friendships

  has_many :pending_requests, -> { where(confirmed: false).order(created_at: :desc) },
           foreign_key: :friend_id, class_name: 'Friendship', inverse_of: 'user'
  has_many :pending_friends, through: :pending_requests, source: :user

  has_many :sent_requests, -> { where confirmed: false },
           foreign_key: :user_id, class_name: 'Friendship', inverse_of: 'user'
  has_many :sent_friends, through: :sent_requests, source: :friend

  def liked?(post_id)
    likes_given.where(post_id: post_id).any?
  end

  def sent_request?(user)
    sent_requests.where(friend_id: user.id).any?
  end

  def pending_request?(user)
    pending_requests.where(user_id: user.id).any?
  end

  def feed
    Post.where(user_id: friend_ids + [id])
  end

  def pending_friends_notification
    pending_friends.limit(5)
  end

  def friend?(user)
    friends.include?(user)
  end


end
