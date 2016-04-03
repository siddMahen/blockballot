contract owned {
    function owned() { owner = msg.sender; }
    address owner;

    modifier onlyowner { if(msg.sender == owner) _ }
}

contract Election is owned {
    struct Candidate {
        bytes32 name;
        uint numVotes;
    }

    struct Voter {
        bool hasVoted;
        bool hasRegistered;
    }

    mapping(address => Voter) public voters;
    mapping(bytes32 => Candidate) public candidates;
    bytes32[] candidateNames;

    uint public electionStartTime;
    uint public electionEndTime;

    event VoteCast(address voter, bytes32 candidateName);
    event ElectionResult(bytes32 candidateName);

    modifier onlybefore(uint _time) { if (now >= _time) throw; _ }
    modifier onlyafter(uint _time) { if (now <= _time) throw; _ }

    function Election(uint start, uint end) {
        electionStartTime = start;
        electionEndTime = end;
    }

    function registerCandidate(bytes32 _name)
        onlyowner
        onlybefore(electionStartTime)
    {
        uint len = candidateNames.length;

        for (uint i = 0; i < len; i++) {
            if (candidateNames[i] == _name) throw;
        }

        candidates[_name] = Candidate({ name: _name, numVotes: 0 });
        candidateNames.push(_name);
    }

    function registerVoter(address voter)
        onlyowner
        onlybefore(electionStartTime)
    {
       voters[voter].hasRegistered = true;
    }

    function electionResults()
        onlyafter(electionEndTime)
    returns (bytes32) {
        uint length = candidateNames.length;
        bytes32 winner = 0x00;
        uint maxVotes = 0;

        for (uint i = 0; i < length; i++) {
            bytes32 name = candidateNames[i];
            if (candidates[name].numVotes > maxVotes) {
                winner = name;
            }
        }

        return winner;
    }

    function vote(bytes32 candidate)
        onlyafter(electionStartTime)
        onlybefore(electionEndTime)
    {
        Voter voter = voters[msg.sender];

        if (voter.hasVoted || !voter.hasRegistered) throw;

        voter.hasVoted = true;
        candidates[candidate].numVotes += 1;

        VoteCast(msg.sender, candidate);
    }
}

