// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract eVoting {
    address public owner;

    constructor() {
        owner = msg.sender;
        currentPhase = Phase.Close;
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    struct candidate {
        /// who stand in the vote
        uint id;
        string name;
        uint age;
        string qualification;
        string party;
        uint voteCount; // how namy votes he got
    }

    struct voter {
        // this is a normal user who can vote
        string name;
        uint age;
        uint voterId;
    }
    uint public voterCount; //for generate Id dynamically...

    struct election {
        string electionName;
        uint[] candidateIds; // we can use mapping here also mulltiple candidate can join in election set by only owner
    }

    enum Phase {
        Registration,
        Voting,
        Result,
        Close
    } //0,1,2,3
    Phase public currentPhase;

    struct CandidateInfo {
        // display the candidate ..
        string name;
        string party;
    }

    mapping(uint => candidate) candidates; // many candidate can add .. and only owner can set the candidate
    mapping(address => voter) voters; // many voter can vote .. in election
    mapping(uint => election) elections; // many election can be conduct set by only owner
    mapping(address => bool) public isVoter; // to check voter is already registered or not)
    mapping(address => bool) public hasVoted;

    // set phase
    function setPhase(Phase _phase) public onlyOwner {
        currentPhase = _phase;
    }

    //set candidate ..
    function setCandidate(
        uint id,
        string memory _name,
        uint _age,
        string memory _qualification,
        string memory _party
    ) public onlyOwner {
        candidate memory newCandidate = candidate(
            id,
            _name,
            _age,
            _qualification,
            _party,
            0
        );
        candidates[id] = newCandidate;
    }

    // set Election
    uint public electionCount; // <---- ADD THIS

function setElection(
    uint _id,
    string memory _electionName,
    uint[] memory _candidateIds
) public onlyOwner {
    require(_candidateIds.length > 0, "At least one candidate required");
    elections[_id] = election(_electionName, _candidateIds);
    electionCount++; // <---- ADD THIS
}

    //set Voter
    function voterRegistration(string memory _name, uint _age) public {
        require(currentPhase == Phase.Registration, "no registration now ...");
        require(!isVoter[msg.sender], "you already register");
        require(_age >= 18, "You are not eligible to vote");
        isVoter[msg.sender] = true;
        voterCount++;
        voter memory v = voter(_name, _age, voterCount);
        voters[msg.sender] = v;
    }

    // voting the candidate
    function castVote(uint _electionId, uint _candidateId) public {
        require(currentPhase == Phase.Voting, "no vote is start");
        require(isVoter[msg.sender], "You are not registered to vote");
        require(
            !hasVoted[msg.sender],
            "You have already voted in this election"
        );
        require(
            bytes(elections[_electionId].electionName).length != 0,
            "Election does not exist"
        );
        require(
            isCandidateInElection(_electionId, _candidateId),
            "Invalid candidate ID"
        );

        candidates[_candidateId].voteCount++;
        hasVoted[msg.sender] = true;
    }

    // helper function
    function isCandidateInElection(
        uint _electionId,
        uint _candidateId
    ) public view returns (bool) {
        uint[] memory cands = elections[_electionId].candidateIds;

        for (uint i = 0; i < cands.length; i++) {
            if (cands[i] == _candidateId) {
                return true; // candidate found
            }
        }

        return false; // candidate not in the election
    }

    //find wining candidate
    function winningcandidate(
        uint _electionId
    )
        public
        view
        
        returns (
            string memory winnerName,
            string memory partyName,
            uint winnerVotes
        )
    {
        require(currentPhase == Phase.Result, " voting is running ");
        require(
            bytes(elections[_electionId].electionName).length != 0,
            "Invalid election ID"
        );

        uint[] memory cands = elections[_electionId].candidateIds;
        require(cands.length > 0, "No candidates in this election");

        uint maxVotes = 0;
        uint winnerId = cands[0]; // default winner is the first candidate

        for (uint i = 0; i < cands.length; i++) {
            uint cid = cands[i];
            if (candidates[cid].voteCount > maxVotes) {
                maxVotes = candidates[cid].voteCount;
                winnerId = cid;
            }
        }

        return (
            candidates[winnerId].name,
            candidates[winnerId].party, // return party as well
            maxVotes
        );
    }

    // display Candidate for a particular Election ...

    function displayCandidateInfo(
        uint _electionId
    ) public view returns (CandidateInfo[] memory) {
        require(
            bytes(elections[_electionId].electionName).length != 0,
            "Invalid election ID"
        );
        uint[] memory cands = elections[_electionId].candidateIds;
        require(cands.length > 0, "No candidates in this election");

        CandidateInfo[] memory info = new CandidateInfo[](cands.length);
        for (uint i = 0; i < cands.length; i++) {
            info[i] = CandidateInfo({
                name: candidates[cands[i]].name,
                party: candidates[cands[i]].party
            });
        }
        return info;
    }

    function getElection(uint _id) public view returns (string memory name, uint[] memory candidateIds) {
    require(bytes(elections[_id].electionName).length != 0, "Election does not exist");
    election memory e = elections[_id];
    return (e.electionName, e.candidateIds);
}

}
