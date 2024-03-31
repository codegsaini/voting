// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 < 0.9.0;

contract Database {

    event GeneratedUIDOfPoll(uint);
    event OnCandidateAdded(bool);
    event OnCandidateRemoved(bool);
    event OnVoterAdded(bool);
    event OnVoterRemoved(bool);
    event OnPollRemoved(bool);
    event onVoteCastEvent(bool);
    uint randNonce = 0;

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Voter {
        address id;
        bool isVoted;
    }

    struct Poll {
        uint uid;
        string title;
        uint256 startTime;
        uint256 endTime;
        Candidate[] candidates;
        Voter[] voters;
        address organiser;
    }

    mapping(uint => Poll) polls;
    mapping(address => Poll[]) organiserPolls;
    
    function getMyPolls() external view returns(Poll[] memory) {
    	return organiserPolls[msg.sender];
    }

    function createPoll(string memory title, uint256 startTime, uint256 endTime) external {
        uint uid = randMod(100000);
        Poll storage newPoll = polls[uid];
        newPoll.uid = uid;
        newPoll.title = title;
        newPoll.startTime = startTime;
        newPoll.endTime = endTime;
        newPoll.organiser = msg.sender;
        organiserPolls[msg.sender].push(newPoll);
        emit GeneratedUIDOfPoll(uid);
    }

    function addCandidate(uint uid, string memory name) external {
        polls[uid].candidates.push(Candidate({name: name, voteCount: 0}));
        emit OnCandidateAdded(true);
    }

    function removeCandidate(uint uid, uint index) external {
        polls[uid].candidates[index] = polls[uid].candidates[polls[uid].candidates.length - 1];
        polls[uid].candidates.pop();
        emit OnCandidateRemoved(true);
    }

    function addVoter(uint uid, address voterId) external {
        polls[uid].voters.push(Voter({id: voterId, isVoted: false}));
        emit OnVoterAdded(true);
    }

    function removeVoter(uint uid, uint index) public {
        polls[uid].candidates[index] = polls[uid].candidates[polls[uid].candidates.length - 1];
        polls[uid].candidates.pop();
        emit OnVoterRemoved(true);
    }

    function removePoll(uint uid) external {
        delete polls[uid];
        emit OnPollRemoved(true);
    }

    function isVoteCasted(uint pollId) external view returns(bool) {
        for (uint i = 0; i < polls[pollId].voters.length; i++){
            if (polls[pollId].voters[i].id == msg.sender) {
                return polls[pollId].voters[i].isVoted;
            }
        }
        return false;
    }

    function isVoterEligible(uint pollId) external view returns(bool){
        for (uint i = 0; i < polls[pollId].voters.length; i++){
            if(polls[pollId].voters[i].id == msg.sender) return true;
        }
        return false;
    }
    
    function isPollOwner(uint pollId) external view returns(bool){
        return polls[pollId].organiser == msg.sender;
    }

    function getPoll(uint uid) view external returns(Poll memory) {
        return polls[uid];
    }

    function castVote(uint uid, uint index) external {
        for (uint i = 0; i< polls[uid].voters.length; i++) {
            if (polls[uid].voters[i].id == msg.sender) {
                polls[uid].candidates[index].voteCount++;
                polls[uid].voters[i].isVoted = true;
                emit onVoteCastEvent(true);
            }
        }
        emit onVoteCastEvent(false);
    }

    function randMod(uint _modulus) internal returns(uint)
    {
        // increase nonce
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % _modulus;
    } 
}
