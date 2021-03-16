class MainController < ApplicationController
  def index
    require 'json'
    json = File.read('public/files/finished-elections.json')
    @completed_elections = JSON.parse(json)
  end

  def BCExplorer

    type = params[:type]
    @BC_election_data = {}
    case type
    when  "1"
      contract = helpers.get_pre_election_contract
      @headers =  ["Beta", "Encrypted Tracker Number In Group", "Public Key Signature", "Public Key Trapdoor"]
      index = 0
      castVotes = CSV.parse(File.read('public/files/public-voters.csv'), headers: true)
      castVotes.each { |vote|
      bc_data = contract.call.get_voter_record(vote["beta"].to_s).to_a
      if ! bc_data.nil?
        @BC_election_data[index] = bc_data
        index = index + 1
      end
    }
    when "2"
      contract = helpers.get_election_contract
      @headers =  ["Beta", "EncryptedVote", "EncryptedVoteSignature", "EncryptedTrackerNumberInGroup", "PublicKeySignature", "PublicKeyTrapdoor"]
      index = 0
      castVotes = CSV.parse(File.read('public/files/public-encrypted-voters.csv'), headers: true)
      castVotes.each { |vote|
        bc_data = contract.call.get_record(vote["beta"].to_s).to_a
        puts "bcData #{bc_data}"
        if ! bc_data.nil?
          @BC_election_data[index] = bc_data
          index = index + 1
        end
      }
    else 
      contract = helpers.get_post_election_contract   
      @headers =  ["TrackerNumber", "PlainTextVote"]
      index = 0
      plainVotes = CSV.parse(File.read('public/files/public-mixed-voters.csv'), headers: true)
      plainVotes.each { |vote|
      bc_data = contract.call.get_record(vote["trackerNumber"].to_s).to_a
      if ! bc_data.nil?
        @BC_election_data[index] = bc_data
        index = index + 1
      end
    }
    end
  end
end
