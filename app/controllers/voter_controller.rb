class VoterController < ApplicationController
  include Recaptcha::Adapters::ViewMethods
  include Recaptcha::Adapters::ControllerMethods

  before_action :check_voter_session, except: [:login, :elections, :verificationResult, :result]

  protect_from_forgery with: :exception

  def check_voter_session

    puts "check voter session, is session null ?  #{session.nil?}"
    if session[:election].nil?
      flash[:danger] = 'Can not access resource without login. Please login here'
      redirect_to '/voter/elections'
    else
      if session[:expires_at] < Time.current
        flash[:danger] = 'Your login session has been expired. Please, login again.'
        @e_name = session[:election]
        session.clear
        redirect_to '/voter/login?election='+@e_name
      end
    end


  end

  def login
    require 'csv'
    require 'json'
    @voter = params[:voter]
    @election_name = params[:election]
    @voter_list = CSV.parse(File.read("public/files/voters.csv"), headers: true)

    # Date and Time Check against current Date and Time
    jsonObj = File.read('public/files/elections.json')
    elections = JSON.parse(jsonObj)
    election = elections["elections"].select { |obj| obj['name'].to_s == @election_name.to_s}.first
    startTime = Time.parse(election["start_time"])
    endTime   = Time.parse(election["end_time"])
    electionDate = Date.strptime(election["sdate"], '%d-%m-%Y')
    

    @dateCompare = electionDate == Date.today

    @timeCompare = startTime< Time.now && Time.now<endTime

    if !@voter.nil?
      if verify_recaptcha
        @code = @voter[:code]
        table = CSV.parse(File.read('public/files/ers-associated-voters.csv'), headers: true)
        voterID = get_voter_id_by_code(@code)
        if ! voterID.nil?
          voter_obj = table.select { |row| row['id'].to_i == voterID.to_i}.first
          @beta = voter_obj['beta']
        end

        if !voter_obj.nil?
          session[:voter]      = @beta
          session[:expires_at] = Time.current + 10.minutes
          session[:election]   = @election_name
          puts "Creating a session for the current voter"
          #session.keys.each do |key|
          # p "#{key} => #{session[key]}"
          #end
          if votedBefore(@beta).nil?
            redirect_to :controller => 'voter', :action => 'ballot', params: request.query_parameters
          else
            redirect_to :controller => 'voter', :action => 'info'
          end
        else
          flash[:danger] = 'Invalid login code, please check your email and try again.'
          redirect_to '/voter/login/?election='+@election_name
        end
      end

    end
  end

  def get_voter_id_by_code(code)
    require 'csv'
    table = CSV.parse(File.read('public/files/voters.csv'), headers: true)
    voter_obj = table.select { |row| row['code'].to_i == code.to_i}.first
    if !voter_obj.nil?
      return voter_obj['id']
    else
      return nil
    end
  end

  def votedBefore(val)
    registeredVotes = CSV.parse(File.read('public/files/ers-plaintext-voters.csv'), headers: true)
    voter = registeredVotes.select { |row| row['beta'].to_i == val.to_i}.first
    return voter
  end

  def elections
    require 'json'
    json = File.read('public/files/elections.json')
    @parsed_json = JSON.parse(json)
  end

  def ballot
    require 'json'
    json = File.read('public/files/elections.json')
    @parsed_json = JSON.parse(json)
  end

  def logout
    session.clear
    redirect_to '/voter/elections'
  end

  def result
    require 'csv'
    if  !File.exist?('public/files/public-mixed-voters.csv')
      flash[:danger] = 'The election result has not been published yet. Please try later.'
      redirect_to '/voter/info'
    else
    plainVotes = CSV.parse(File.read('public/files/public-mixed-voters.csv'), headers: true)
    @hash = Hash.new(0)
    plainVotes.each { |pVote|
      if !@hash.has_key?(pVote["plainTextVote"])
        freq = score(plainVotes, pVote["plainTextVote"])
        @hash.store(pVote["plainTextVote"], freq)
      end
    }
  end
  end

  def verificationResult
    @election = params[:election]
    @beta     = params[:beta].to_i
    alpha    = params[:alpha]

    encryptedVoters = CSV.parse(File.read('public/files/public-encrypted-voters.csv'), headers: true)
    voter= encryptedVoters.select { |row| row['beta'].to_i == @beta}.first
    if !voter.nil?
    publicTrapdoorKey = voter["publicKeyTrapdoor"].to_i
    keys = CSV.parse(File.read('public/files/voters-keys.csv'), headers: true)
    key =  keys.select { |row| row['publicKeyTrapdoor'].to_i == publicTrapdoorKey}.first

    private_key = key["privateKeyTrapdoor"].to_i

    elections = CSV.parse(File.read('public/files/public-election-params.csv'), headers: true)
    election = elections.select {|row| row["name"].to_s == @election.to_s}.first
    p = election["p"].to_i


    require 'openssl'
    newAlpha = OpenSSL::BN.new(alpha, 10)
    newBeta  = OpenSSL::BN.new(@beta,10)
    newSK    = OpenSSL::BN.new(private_key, 10)
    newP     = OpenSSL::BN.new(p, 10)

    tracker_number_in_group = newAlpha.mod_exp(newP - 1 - newSK, newP).mod_mul(newBeta, newP).to_i

    puts "tracker number in group"
    puts tracker_number_in_group

    trackers = CSV.parse(File.read('public/files/public-tracker-numbers.csv'), headers: true)
    tn = trackers.select {|row| row["trackerNumberInGroup"].to_i == tracker_number_in_group.to_i}.first

    @plainTrackerNumber = tn["trackerNumber"]
    mixed_votes = CSV.parse(File.read('public/files/public-mixed-voters.csv'), headers: true)
    plain_vote_row = mixed_votes.select {|row| row["trackerNumber"].to_i == @plainTrackerNumber.to_i}.first

    @plainVote = plain_vote_row["plainTextVote"]

    puts @plainTrackerNumber
    puts @plainVote
    else
      @error = "No vote associated with these details is found. Please get in touch with administrator."
    end  
  end

  def truncate(string)
    string.length > 8 ? "#{string[0...8]}..." : string
  end

  def summary
    @checkes = params[:candidate]
    @election_name = params[:election]
    @voter = params[:voter]
    puts "try top parse json"
    require 'json'
    json = File.read('public/files/elections.json')
    @parsed_json = JSON.parse(json)
  end

  def score( array, vote )
    count = 0
    for obj in array
      if obj["plainTextVote"] == vote
        count += 1
      end
    end
    return count

    #hash = Hash.new(0)
    #array.each{|key| hash[key] += 1}
    #hash
  end

  def castVote

    require 'csv'
    require 'openssl'
   
    betaVal = session[:voter] #params[:voter]

    if votedBefore(betaVal).nil?
      plainVote =  params[:vote]
      voters = CSV.parse(File.read('public/files/ers-associated-voters.csv'), headers: true)
      voter = voters.select { |row| row['beta'].to_i == betaVal.to_i}.first

      CSV.open( 'public/files/ers-plaintext-voters.csv', 'a+' ,:headers => true, quote_char: " ") do |writer|
        writer.puts(["\"#{betaVal.to_s}\"", voter["id"].to_i, "\"#{plainVote.to_s}\"", "\"#{voter["encryptedTrackerNumberInGroup"].to_s}\"", "\"#{voter["publicKeySignature"].to_s}\"", "\"#{voter["publicKeyTrapdoor"].to_s}\""])
      end

      flash[:success] = 'Your vote has been successfully recorded. Thank you for participating.'
      electionName = session[:election]
      session.clear
      redirect_to '/voter/login?election='+electionName

    else
      puts "you have votes before."
    end
  end


end
