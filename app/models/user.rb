class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy

  # As a follower
  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :follows, source: :followed

  # As a followed user
  has_many :reverse_follows, foreign_key: :followed_id, class_name: "Follow", dependent: :destroy
  has_many :followers, through: :reverse_follows, source: :follower

  validates :name, presence: true

  def following?(other_user)
    following.include?(other_user)
  end

  def follow(other_user)
    follows.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    follows.find_by(followed_id: other_user.id)&.destroy
  end
end
