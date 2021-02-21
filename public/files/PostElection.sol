pragma solidity >0.6.4;
pragma experimental ABIEncoderV2;

contract PostElection{

    address owner;
    struct PlainRecords{
        string trackerNumber;
        string plainTextVote;

    }

    mapping(string => PlainRecords) records;
    string[] public plainList;

    constructor() public {
        owner = msg.sender;
    }

    function addRecord(string memory _trackerNumber, string memory _plainTextVote) public
    returns (bool success)
      {
        records[_trackerNumber].trackerNumber = _trackerNumber;
        records[_trackerNumber].plainTextVote = _plainTextVote;
        plainList.push(_trackerNumber);

        return true;
      }

    function getRecord(string memory _plainTrackerNumber) public view
    returns(string memory _trackerNumber, string memory _plainVote)
      {
        return(records[_plainTrackerNumber].trackerNumber, records[_plainTrackerNumber].plainTextVote);
      }

    function getStoredPlainCount() public view
    returns(uint  plainCount)
      {
        return plainList.length;
      }

      function getList() public view
      returns (string[] memory list)
      {
      return plainList;
      }



}