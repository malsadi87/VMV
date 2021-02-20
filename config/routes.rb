Rails.application.routes.draw do
  #get 'main/index'
  get "/main", to: "main#index"
  get "main/verifiable"
  get "main/elections"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
