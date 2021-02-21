Rails.application.routes.draw do
  #admin controller - GET
  get "admin/index"
  get 'admin/dashboard'
  get 'admin/elections'
  get 'admin/startElection'
  get 'admin/newElection'
  get 'admin/sendVerifiactionParams'
  get 'admin/uploadPreElectionToBC'

  #admin controller - POST
  post 'login' => 'admin#index', as: :login
  post "admin/index" => "admin#index"
  post "admin/newElection" => "admin#newElection"
  post "admin/sendVerificationParams" => "admin#sendVerificationParams"
  post "admin/uploadPreElectionToBC" => "admin#uploadPreElectionToBC"
  post "admin/startElection" => "admin#startElection"

  #main controller - GET
  get "/main", to: "main#index"
  get "main/verifiable"
  get "main/elections"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
