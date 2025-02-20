class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy  

  # As a follower
  has_many :following, through: :follows, source: :followed
  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  
  # As a followed user
  has_many :followers, through: :following_users, source: :follower
  has_many :following_users, foreign_key: :followed_id, class_name: "Follow", dependent: :destroy
end
