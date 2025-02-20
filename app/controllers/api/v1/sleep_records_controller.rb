module Api
  module V1
    class SleepRecordsController < ApplicationController

      # GET /v1/sleep_records
      def index
        @sleep_records = current_user.sleep_records.ordered_by_created
        render json: @sleep_records
      end
    end
  end
end