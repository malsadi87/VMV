pragma solidity >0.6.4;
contract PreElection{

    address owner;
    struct VoterRecords{
        string beta;
        string encryptedTrackerNumberInGroup;
        string publicKeySignature;
        string publicKeyTrapdoor;
    }

    mapping(string => VoterRecords) voters;
    string[] public voterList;

    constructor() public {
        owner = msg.sender;
    }

    function addVoterEntry( string memory _beta, string memory _encryptedTrackerNumberInGroup, string memory _publicKeySignature, string memory _publicKeyTrapdoor) public
    returns (bool success)
      {
        voters[_beta].beta = _beta;
        voters[_beta].encryptedTrackerNumberInGroup = _encryptedTrackerNumberInGroup;
        voters[_beta].publicKeySignature = _publicKeySignature;
        voters[_beta].publicKeyTrapdoor =  _publicKeyTrapdoor;
        voterList.push(_beta);

        return true;
      }

    function getVoterRecord(string memory _beta) public view
    returns(string memory _b, string memory _enc, string memory _pkS, string memory _pkT)
      {
        return(voters[_beta].beta, voters[_beta].encryptedTrackerNumberInGroup, voters[_beta].publicKeySignature, voters[_beta].publicKeyTrapdoor);
      }

    function getStoredVotersCount() public view
    returns(uint  votersCount)
      {
        return voterList.length;
      }



}