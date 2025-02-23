module Api
  module V1
    class FollowsController < ApplicationController
      # POST /v1/follows
      def create
        user_to_follow = User.find(params[:followed_id])

        follow = current_user.follow(user_to_follow)

        if follow.valid?
          Rails.cache.delete(sleep_records_cache_key)
          render json: { status: "success", message: "Successfully followed user" }, status: :created
        else
          render json: { errors: follow.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /v1/follows/:id
      def destroy
        follow = current_user.follows.find_by(followed_id: params[:id])

        if follow
          follow.destroy
          Rails.cache.delete(sleep_records_cache_key)
          render json: { status: "success", message: "Successfully unfollowed user" }
        else
          render json: { error: "Follow relationship not found" }, status: :not_found
        end
      end

      # GET /v1/follows/following_sleep_records
      def following_sleep_records
        render json: sleep_records, include: { user: { only: [:id, :name] } }
      end

      private

      def sleep_records
        Rails.cache.fetch(sleep_records_cache_key, expires_in: 5.minutes) do
          following_ids = current_user.following.pluck(:id)

          SleepRecord.where(user_id: following_ids)
                     .complete
                     .from_past_week
                     .includes(:user)
                     .order(duration_minutes: :desc)
                     .page(params[:page]).per(20).to_a
        end
      end

      def sleep_records_cache_key
        "user:#{current_user.id}:following_sleep_records"
      end
    end
  end
end