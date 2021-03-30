Rails.application.routes.draw do
  get 'election/index'
  get 'election/view'
  get 'election/uploads'
  get 'election/record'
  post 'election/record' => 'election#record'
  get 'voter/login'
  get 'voter/elections'
  get 'voter/ballot'
  get 'voter/result'
  get 'voter/verificationResult'
  get 'voter/summary'
  get 'voter/info'
  get 'voter/logout'

  #voter controller - POST
  post "voter/login" => "voter#login"
  post "voter/ballot" => "voter#summary"
  post "voter/summary" => "voter#castVote"
  post "voter/info" => "voter#info"
  post "voter/logout" => "voter#logout"


  #admin controller - GET
  
  get "admin/index"
  get 'admin/dashboard'
  get 'admin/elections'
  get 'admin/startElection'
  get 'admin/newElection'
  get 'admin/sendVerificationParams'
  get 'admin/uploadPreElectionToBC'
  get 'admin/logout'

  #admin controller - POST
  post 'login' => 'admin#index', as: :login
  post "admin/index" => "admin#index"
  post "admin/newElection" => "admin#newElection"
  post "admin/sendVerificationParams" => "admin#sendVerificationParams"
  post "admin/uploadPreElectionToBC" => "admin#uploadPreElectionToBC"
  post "admin/startElection" => "admin#startElection"
  post "admin/logout" => "admin#logout"

  #main controller - GET
  get "/", to: "main#index"
  get "/main", to: "main#index"
  get "main/verifiable"
  get "main/elections"
  get "main/BCExplorer"
  get "main/introduction"
  get "main/about"
  get "main/documents"
  #match 'election/record' => 'election#record', :as => :get_election_record, :via => [:get, :post]


  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
