# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'search', to: 'companies#search'
    end
  end
end