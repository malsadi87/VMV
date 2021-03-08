pragma solidity >0.6.4;
pragma experimental ABIEncoderV2;

contract Election{

    address owner;
    struct EncryptedRecords{
        string beta;
        string encryptedVote;
        string encryptedVoteSignature;
        string encryptedTrackerNumberInGroup;
        string publicKeySignature;
        string publicKeyTrapdoor;
    }

    mapping(string => EncryptedRecords) ciphers;
    string[] public cipherList;

    constructor() public {
        owner = msg.sender;
    }

    function addRecord(string memory _beta,
                               string memory _encryptedVote,
                               string memory _encryptedVoteSignature,
                               string memory _encryptedTrackerNumberInGroup,
                               string memory _publicKeySignature,
                               string memory _publicKeyTrapdoor) public
    returns (bool success)
      {
        ciphers[_beta].beta = _beta;
        ciphers[_beta].encryptedVote = _encryptedVote;
        ciphers[_beta].encryptedVoteSignature = _encryptedVoteSignature;
        ciphers[_beta].encryptedTrackerNumberInGroup = _encryptedTrackerNumberInGroup;
        ciphers[_beta].publicKeySignature = _publicKeySignature;
        ciphers[_beta].publicKeyTrapdoor = _publicKeyTrapdoor;
        cipherList.push(_beta);
        return true;
      }

    function getRecord(string memory _beta) public view
    returns(string memory beta,
                                           string memory _encryptedVote,
                                           string memory _encryptedVoteSignature,
                                           string memory _encryptedTrackerNumberInGroup,
                                           string memory _publicKeySignature,
                                           string memory _publicKeyTrapdoor)
      {
        return(ciphers[_beta].beta, ciphers[_beta].encryptedVote, ciphers[_beta].encryptedVoteSignature,
               ciphers[_beta].encryptedTrackerNumberInGroup, ciphers[_beta].publicKeySignature, ciphers[_beta].publicKeyTrapdoor);
      }

    function getStoredCipherCount() public view
    returns(uint  plainCount)
      {
        return cipherList.length;
      }

      function getList() public view
      returns (string[] memory list)
      {
      return cipherList;
      }



}