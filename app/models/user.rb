class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy

  # As a follower
  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :follows, source: :followed
  
  # As a followed user
  has_many :following_users, foreign_key: :followed_id, class_name: "Follow", dependent: :destroy
  has_many :followers, through: :following_users, source: :follower


  def following?(other_user)
    following.include?(other_user)
  end

  def follow(other_user)
    follows.create(followed_id: other_user.id) unless self == other_user || following?(other_user)
  end
end
