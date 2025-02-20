module Api
  module V1
    class SleepRecordsController < ApplicationController
      before_action :set_sleep_record, only: [:clock_out]

      # GET /v1/sleep_records
      def index
        @sleep_records = current_user.sleep_records.ordered_by_created
        render json: @sleep_records
      end
      
      # POST /v1/sleep_records/clock_in
      def clock_in
        # Check if there's already an active sleep record
        if current_user.sleep_records.incomplete.exists?
          return render json: { error: "You already have an active sleep session" }, status: :unprocessable_entity
        end
        
        @sleep_record = current_user.sleep_records.create!(clock_in_at: Time.current)
        
        # Return all clock-in times ordered by created time
        @sleep_records = current_user.sleep_records.ordered_by_created
        render json: @sleep_records, status: :created
      end
      
      # PATCH /v1/sleep_records/:id/clock_out
      def clock_out
        if @sleep_record.clock_out_at.present?
          return render json: { error: "Sleep record already clocked out" }, status: :unprocessable_entity
        end
        
        @sleep_record.update!(clock_out_at: Time.current)
        render json: @sleep_record
      end

      private
      
        def set_sleep_record
          @sleep_record = current_user.sleep_records.find(params[:id])
        end
    end
  end
end