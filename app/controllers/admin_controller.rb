class AdminController < ApplicationController
  include BlockchainHelper

  before_action :check_admin_session, except: [:index]

  def index
    puts "welcome to index method"
    @user = params[:user]
    if !@user.nil?
      @email = @user[:email]
      @pass = @user[:password]
      if @email == "admin@admin.com" && @pass == "password"
        puts "Login success"
        session[:user]      = @email
        session[:expires_at] = Time.current + 10.minutes
        redirect_to :controller => 'admin', :action => 'dashboard', :name => @email
      else
        puts "try again later"
        flash[:warn] = 'Wrong email/password'
        redirect_to '/admin/index'

      end
    end
  end

  def dashboard
  end

  def elections
    require 'json'
    json = File.read('public/files/elections.json')
    puts "View Elections method"
    puts json
    @ElectionArray = JSON.parse(json)
  end

  def startElection
  end

  def newElection

    @election = params[:election]
    if !@election.nil?
      require 'json'
      #@candidates = [{"id"=> 1, "name"=> "John David"}, {"id"=> 2, "name"=> "Stephane William"},{"id"=> 3, "name"=> "Hanna Peter"},{"id"=> 4, "name"=> "Michel Nimar"},{"id"=> 5, "name"=> "Marry John"}]
      tempHash = {"id" => @election[:id], "name" => @election[:name], "sdate" => @election[:sdate], "location" => @election[:location], "candidates" => @candidates }
      #json = File.read('public/elections.json')
      #puts json
      #@Array = JSON.parse(json)
      #@eArr = @Array['elections']

      #puts @Array
      #puts @eArr
      #@eArr << tempHash

      #File.open("public/elections.json","w") do |f|
      #  f.puts JSON.pretty_generate(@Array)
      #end
      flash[:notice] = 'Successfully generated  '  +  tempHash  

    end
    puts "Generate Election Method main page"

  end

  def sendVerifiactionParams
  end

  def uploadPreElectionToBC
    @uploaded = false
    puts "Pre Election files to Blockchain"
    contract = helpers.get_pre_election_contract
    if contract.nil?
      helpers.create_pre_election_contract
      contract = helpers.get_pre_election_contract
    end
    if ! contract.nil?
    publicVoters = CSV.parse(File.read('public/files/public-voters.csv'), headers: true)
    publicVoters.each do |voter|
      contract.transact_and_wait.add_voter_entry(voter["beta"].to_s, voter["encryptedTrackerNumberInGroup"].to_s, voter["publicKeySignature"].to_s, voter["publicKeyTrapdoor"].to_s)
    end
    @uploaded = true
    puts "uploaded value is #{@uploaded}"
    flash[:success] = 'PreElection voters details are published to Blockchain.'
    redirect_to '/admin/elections'
    end

  end



  def check_admin_session

    puts "check admin session, is session null ?  #{session.nil?}"
    if session[:user].nil?
      flash[:danger] = 'Can not access resource without login. Please login here'
      redirect_to '/admin/index'
    else
      if session[:expires_at] < Time.current
        flash[:danger] = 'Your login session has been expired. Please, login again.'
        session.clear
        redirect_to '/admin/index'
      end
    end


  end

end
