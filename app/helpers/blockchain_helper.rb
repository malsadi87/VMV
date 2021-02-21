module BlockchainHelper

    require 'csv'
    require 'ethereum.rb'
    require 'eth'
  
    $pre_contract_name = "PreElection.sol"
    $pre_contract_loc  = "public/files/PreElection.sol"
    $pre_contract_abi  = '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"string","name":"_beta","type":"string"},{"internalType":"string","name":"_encryptedTrackerNumberInGroup","type":"string"},{"internalType":"string","name":"_publicKeySignature","type":"string"},{"internalType":"string","name":"_publicKeyTrapdoor","type":"string"}],"name":"addVoterEntry","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getStoredVotersCount","outputs":[{"internalType":"uint256","name":"votersCount","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"_beta","type":"string"}],"name":"getVoterRecord","outputs":[{"internalType":"string","name":"_b","type":"string"},{"internalType":"string","name":"_enc","type":"string"},{"internalType":"string","name":"_pkS","type":"string"},{"internalType":"string","name":"_pkT","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"voterList","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"}]'
    $pre_contract = nil
    $pre_contract_address = nil
  
  
    $ele_contract_name = "Election.sol"
    $ele_contract_abi  = '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"string","name":"_beta","type":"string"},{"internalType":"string","name":"_encryptedVote","type":"string"},{"internalType":"string","name":"_encryptedVoteSignature","type":"string"},{"internalType":"string","name":"_encryptedTrackerNumberInGroup","type":"string"},{"internalType":"string","name":"_publicKeySignature","type":"string"},{"internalType":"string","name":"_publicKeyTrapdoor","type":"string"}],"name":"addRecord","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"cipherList","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getList","outputs":[{"internalType":"string[]","name":"list","type":"string[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"_beta","type":"string"}],"name":"getRecord","outputs":[{"internalType":"string","name":"beta","type":"string"},{"internalType":"string","name":"_encryptedVote","type":"string"},{"internalType":"string","name":"_encryptedVoteSignature","type":"string"},{"internalType":"string","name":"_encryptedTrackerNumberInGroup","type":"string"},{"internalType":"string","name":"_publicKeySignature","type":"string"},{"internalType":"string","name":"_publicKeyTrapdoor","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getStoredCipherCount","outputs":[{"internalType":"uint256","name":"plainCount","type":"uint256"}],"stateMutability":"view","type":"function"}]'
    $ele_contract_loc  = "public/files/Election.sol"
    $ele_contract = nil
    $ele_contract_address = nil
  
  
    $pst_contract_name = "PostElection.sol"
    $pst_contract_abi  = '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"string","name":"_trackerNumber","type":"string"},{"internalType":"string","name":"_plainTextVote","type":"string"}],"name":"addRecord","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getList","outputs":[{"internalType":"string[]","name":"list","type":"string[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"_plainTrackerNumber","type":"string"}],"name":"getRecord","outputs":[{"internalType":"string","name":"_trackerNumber","type":"string"},{"internalType":"string","name":"_plainVote","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getStoredPlainCount","outputs":[{"internalType":"uint256","name":"plainCount","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"plainList","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"}]'
    $pst_contract_loc  = "public/files/PostElection.sol"
    $pst_contract = nil
    $pst_contract_address = nil
  
  
    $EthClient = Ethereum::HttpClient.new('http://127.0.0.1:7545')
  
  
    def get_client
      return $EthClient
    end
  
    def create_pre_election_contract
  
      $pre_contract = Ethereum::Contract.create(client: $EthClient, file: $pre_contract_loc)
      $pre_contract_address = $pre_contract.deploy_and_wait
      puts "create PreElection contract with address #{$pre_contract_address}"
      ##saving contract info details
      CSV.open( 'public/files/contracts.csv', 'a+' ,:headers => true, quote_char: " ") do |writer|
        writer.puts(["\"#{$pre_contract_name}\"", "\"#{$pre_contract_address}\""])
      end
  
    end
  
    def get_pre_election_contract
  
      contracts = CSV.parse(File.read('public/files/contracts.csv'), headers: true)
      vote_contract = contracts.select { |row| row['name'].to_s == $pre_contract_name.to_s}.first
      if !vote_contract.nil?
      contract = Ethereum::Contract.create(client: $EthClient, name: "PreElection", address: vote_contract["address"], abi: $pre_contract_abi)
      return contract
      end
    end
  
    def get_pre_election_contract_address
      return $pre_contract_address
    end
  
    def get_pre_election_contract_abi
      return $pre_contract_abi
    end
  
  
    ## Voting Election Contract methods
    def create_election_contract
      $ele_contract         = Ethereum::Contract.create(client: $EthClient, file: $ele_contract_loc)
      $ele_contract_address = $ele_contract.deploy_and_wait
  
      ##saving contract info details
      CSV.open( 'public/files/contracts.csv', 'a+' ,:headers => true, quote_char: " ") do |writer|
        writer.puts(["\"#{$ele_contract_name}\"", "\"#{$ele_contract_address}\""])
      end
  
    end
  
    def get_election_contract
  
      contracts = CSV.parse(File.read('public/files/contracts.csv'), headers: true)
      vote_contract = contracts.select { |row| row['name'].to_s == $ele_contract_name.to_s}.first
      if !vote_contract.nil?
      contract = Ethereum::Contract.create(client: $EthClient, name: "Election", address: vote_contract["address"], abi: $ele_contract_abi)
      return contract
      end
    end
  
    def get_election_contract_address
      return $ele_contract_address
    end
  
    def get_election_contract_abi
      return $ele_contract_abi
    end
  
  
    # Post election Contract methods
    #
    def create_post_election_contract
      $pst_contract = Ethereum::Contract.create(client: $EthClient, file: $pst_contract_loc)
      $pst_contract_address = $pst_contract.deploy_and_wait
  
      ##saving contract info details
      CSV.open( 'public/files/contracts.csv', 'a+' ,:headers => true, quote_char: " ") do |writer|
        writer.puts(["\"#{$pst_contract_name}\"", "\"#{$pst_contract_address}\""])
      end
  
    end
  
    def get_post_election_contract
  
      contracts = CSV.parse(File.read('public/files/contracts.csv'), headers: true)
      if !contracts.nil?
      vote_contract = contracts.select { |row| row['name'].to_s == $pst_contract_name.to_s}.first
      if ! vote_contract.nil?
         contract = Ethereum::Contract.create(client: $EthClient, name: "PostElection", address: vote_contract["address"], abi: $pst_contract_abi)
         return contract
      end
      end
    end
  
    def get_post_election_contract_address
      return $pst_contract_address
    end
  
    def get_post_election_contract_abi
      return $pst_contract_abi
    end
  
  
  
  end
  