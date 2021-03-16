class AdminController < ApplicationController
  include BlockchainHelper
  include ApplicationHelper

  before_action :check_admin_session, except: [:index]
  protect_from_forgery with: :exception

  def index
    puts "welcome to index method"
    @user = params[:user]
    if !@user.nil?
      @email = @user[:email]
      @pass = @user[:password]
      if @email == Rails.application.credentials.admin.dig(:email) && @pass == Rails.application.credentials.admin.dig(:password)
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

  def logout
    session.clear
    redirect_to '/admin/index'
  end

  def dashboard
  end

  def elections
    require 'json'
    json = File.read('public/files/elections.json')
    
    array = JSON.parse(json)
    elections = array['elections']
    result = elections.select { |hash| hash["active"].to_s == "true" }
    puts "result od elections"
    puts result.length
    @ElectionArray = result
  end

  def startElection

    require 'json'
    require 'csv'

    @VotersList = CSV.parse(File.read('public/files/voters.csv'), headers: true)
    table = CSV.parse(File.read('public/files/ers-associated-voters.csv'), headers: true)

    name = params[:election]

    @VotersList.each do |voter|
      puts "voter id = #{voter["id"]} and code = #{voter["code"]}"
      voter_obj = table.select { |row| row['id'].to_i == voter["id"].to_i}

      helpers.beta(voter_obj.first["beta"])
      helpers.loglink("https://vmv1.surrey.ac.uk/voter/login?election=#{name}")
      helpers.code(voter["code"])

      ## Send an email with token to voters' email
      if voter["id"] == "4"
       UserMailer.welcome_email(voter["email"]).deliver
      end
    end

    ## Generate OTPs and send them to voters phones
    #helpers.send_otp

    flash[:success] = 'Emails with login credential are sent to voters.'
    redirect_to '/admin/elections'

  end

  def newElection
    require 'csv'
    require 'json'

    @election = params[:election]
    @candidates = Array.new
      if !@election.nil?
      uploaded_io = params[:candidateList]
      uploadedCandidates = CSV.parse(File.read(uploaded_io.path), headers: true)
      uploadedCandidates.each do |candidate| 
        @candidates << {"id"=> candidate["id"], "name"=> candidate["name"]}
      end

      newID = get_next_election_id.to_i + 1
       
      tempHash = {"id" => newID.to_s, "name" => @election[:name], "sdate" => @election[:sdate], "edate" => @election[:edate], "start_time" => @election[:stime], "end_time" => @election[:etime], "active" => "true" ,"candidates" => @candidates }
      json = File.read('public/files/elections.json')
      @Array = JSON.parse(json)
      @eArr = @Array['elections']
      @eArr << tempHash
      File.open("public/files/elections.json","w") do |f|
        f.puts JSON.pretty_generate(@Array)
      end
      flash[:success] = 'The election is successfully generated. '  
      redirect_to '/admin/dashboard'
     
    else
      puts "election is null"
    end
  end

  def sendVerificationParams
    require 'json'
    require 'csv'
    @VotersList = CSV.parse(File.read('public/files/voters.csv'), headers: true)
    table = CSV.parse(File.read('public/files/ers-associated-voters.csv'), headers: true)
    name = params[:election]

    @VotersList.each do |voter|
      puts %(voter id : '#{voter["id"]}')
      voter_obj = table.select { |row| row['id'].to_i == voter["id"].to_i}
      vBeta = voter_obj.first["beta"]
      helpers.beta(vBeta)
      vAlpha = getAlphaValue(voter["id"])
      helpers.name(voter["name"])
      helpers.loglink("http://localhost:3000/voter/verificationResult?election=#{name}&beta=#{vBeta}&alpha=#{vAlpha}")
      ## Send an email with token to voters' email
      if voter["id"].to_i == 4
        UserMailer.verification_email(voter["email"]).deliver
      end
    end
    

    ## Blockchain Part - Encrypted Votes
    contract = helpers.get_election_contract
    if contract.nil?
      helpers.create_election_contract
      contract = helpers.get_election_contract
    end
    encrypedVotes= CSV.parse(File.read('public/files/public-encrypted-voters.csv'), headers: true)
    contract.gas_price = 0
    contract.gas_limit = 8_000_000
    encrypedVotes.each do |vote|
      contract.transact_and_wait.add_record(vote["beta"].to_s, vote["encryptedVote"].to_s, vote["encryptedVoteSignature"].to_s, vote["encryptedTrackerNumberInGroup"].to_s, vote["publicKeySignature"].to_s, vote["publicKeyTrapdoor"].to_s)
    end

    ## Blockchain part - Plain Votes
    post_contract = helpers.get_post_election_contract
    if post_contract.nil?
      helpers.create_post_election_contract
      post_contract = helpers.get_post_election_contract
    end
    finalVotes= CSV.parse(File.read('public/files/public-mixed-voters.csv'), headers: true)

    finalVotes.each do |vote|
      post_contract.transact_and_wait.add_record(vote["trackerNumber"].to_s, vote["plainTextVote"].to_s)
    end
    flash[:success] = 'Verification parameters are sent successfully. Election Data is stored on Blockchain'
    redirect_to '/admin/elections'
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

  def getAlphaValue(val)
    
    require 'csv'
    encryptedVoters = CSV.parse(File.read('public/files/ers-encrypted-voters.csv'), headers: true)
    record = encryptedVoters.select { |row| row['id'].to_i == val.to_i}.first
    return record['alpha']
  end


  def get_next_election_id
    require 'json'
    elections = File.read('public/files/elections.json')
    return JSON.parse(elections)["elections"].size
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
