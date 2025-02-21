module Api
  module V1
    class FollowsController < ApplicationController

      # POST /v1/follows
      def create
        user_to_follow = User.find(params[:followed_id])

        follow = current_user.follow(user_to_follow)

        if follow.valid?
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
          render json: { status: "success", message: "Successfully unfollowed user" }
        else
          render json: { error: "Follow relationship not found" }, status: :not_found
        end
      end

      # GET /v1/follows/following_sleep_records
      def following_sleep_records
        following_ids = current_user.following.pluck(:id)

        if following_ids.empty?
          return render json: [], status: :ok
        end

        # Get sleep records from the past week of all followed users
        @sleep_records = SleepRecord.where(user_id: following_ids)
                                    .complete
                                    .from_past_week
                                    .includes(:user)
                                    .order(duration_minutes: :desc)
                                    .page(params[:page]).per(20)

        render json: @sleep_records, include: { user: { only: [:id, :name] } }
      end
    end
  end
end