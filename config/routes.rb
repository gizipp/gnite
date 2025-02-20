Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :sleep_records, only: [:index] do
        collection do
          post :clock_in
        end
        member do
          patch :clock_out
        end
      end
      
      resources :follows, only: [:create, :destroy] do
        collection do
          get :following_sleep_records
        end
      end
    end
  end
end