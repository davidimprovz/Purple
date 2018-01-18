// voting.sol

/* 
A useful mechanism for moderating / managing a democratic blockchain group.
Put globally delegated tasks in the organization up for a vote. 

All essential tasks that require oversight should probably be managed internally 
by a steering group, i.e., a governing board, acting as fiduciaries. 

To do this, create a managing board as 

struct Boardmember {
	address public member;
	uint weight;
	uint vote; 
	... etc
}

with a mapping (address => Boardmember) public boardmembers.

and write the functions to manage those aspects of the contract.
*/

pragma solidity ^0.4.16;

// a ballot that allows delegated voting priviliges 
contract Ballot {

	// variables that get initialized upon instantiation of Ballot: 
	// • voter, 
	// • proposal, 
	// • chairperson, 
	// • voters, and 
	// • proposals 

    struct Voter { // a single voter framework for key variables
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    struct Proposal { // holds the data of a single proposal.
        bytes32 name;   // its name (up to 32 bytes)
        uint voteCount; // and its vote count
    }

    address public chairperson; // moderator...whoever instantiates the Ballot.

    mapping(address => Voter) public voters; // stores all voters in one place with the voter's a hash address––sent in a msg with a vote––as the lookup.

    // A dynamically-sized array of `Proposal` structs...the size is decided in Ballot() with instantiation.
    Proposal[] public proposals;

    // instantiate the ballot contract, which creates a Voter struct, Proposal struct, chairperson, a mapping of voters, and a list of proposals
    function Ballot(bytes32[] proposalNames) public {
        chairperson = msg.sender; // every ballot starts out with a chairperson
        voters[chairperson].weight = 1; // set chairperson's vote weight
        for (uint i = 0; i < proposalNames.length; i++) { // for however many proposals are initialized
            proposals.push(Proposal({ // make a proposal and push it onto the proposals array
                name: proposalNames[i], // set the name
                voteCount: 0 // initialize vote count
            }));
        }
    }

    // might be useful to modify function, allowing arrays of voters to be passed and processed with only 1 transaction instead of multiple calls 
    function giveRightToVote(address voter) public { // Give someone the right to vote
        // If `require` is `false`, it terminates and reverts all changes to the state and to Ether balances.
        // It's good idea to use require() so functions aren't called incorrectly. 
        // But watch out!! Using require() will––as of this pragma––consume all provided gas.
        // Future pragmas are not expected to consume gas.
        require((msg.sender == chairperson) && !voters[voter].voted && (voters[voter].weight == 0)); // ensure chairperson is assigining voting rights, the voter cannot have voted, and a voter's weight must be zero
        voters[voter].weight = 1; // voter gets to vote 
    }

    function delegate(address to) public { // Anyone can delegate their vote to the address / person of their choosing.
        Voter storage sender = voters[msg.sender]; // make a sender variable that is stored in contract "storage" for later reference
        require(!sender.voted); // make sure the voter hasn't voted yet
        require(to != msg.sender); // a voter cannot delegate to themselves. duh.

        while (voters[to].delegate != address(0)) { // Forward the delegation as long as `to` also delegated. The address cannot be empty, i.e., 0.
            to = voters[to].delegate; // look up the delegate status of another voter and assign to to.
            require(to != msg.sender); // now make sure that to is not also the sender, which would create a loop.
            // Note: loops can be dangerous. Think carefully about what cases might cause infinite loops.
            // If loops run too long, they might require more gas than is available in a block. 
            // In this case, the delegation will not be executed. And in other situations, such loops can 
            // cause a contract to get "stuck" completely.
        } 

        // Note: If the voter has delegated, create ability for voter to retract the delegation, or to automatically retract by exercising their vote.

        sender.voted = true; // make sure the delegator has their vote marked as true. `sender` points to `voters[msg.sender].voted`.
        sender.delegate = to; // keep track of the address that the voter delegated to. 
        Voter storage delegate = voters[to]; // reference the struct of the new voter, i.e., the delegate.
        
        if (delegate.voted) { // check if the delegate already voted
            proposals[delegate.vote].voteCount += sender.weight; // If so, find the proposal struct with delegate.vote (i.e., the numbered proposal) and add the sender's weight to the delegate's count.
            // this basically allows for people to vote someone else's conscience. If you believe someone else has a better handle on the subject under vote, you don't have 
            // to spend time thinking about it.
        } else { 
            delegate.weight += sender.weight; // if the delegated voter hasn't voted, add the sender's weight to the delegate's weight. 
        }
    }

    // might be useful to add argument of vote arrays that can be processed in single transaction 
    function vote(uint proposal) public { // Give your vote (+ votes delegated to you) to a proposal `proposals[proposal].name`.
        Voter storage sender = voters[msg.sender]; // make a reference to the voter
        require(!sender.voted); // make sure the voter has not voted
        sender.voted = true; // mark them as having voted ... this might be moved to after the vote is cast to ensure no out-of-gas issues.
        sender.vote = proposal; // mark which proposal your votes are going for.

        proposals[proposal].voteCount += sender.weight; // find the proposal by its number and add your weight to it. 
        // Note: If your `proposal` is out of the range of the array, this will throw automatically and revert all changes.
    }

    function winningProposal() public view returns (uint winningProposal) { // get count of all votes. 
    	// Note: presumably the contract will include a date-time reference to end the vote, or give this capability  
    	// to the chairperson. 
        uint winningVoteCount = 0; // start a counter
        for (uint p = 0; p < proposals.length; p++) { // you're going to get the counts of all proposals recursively
            if (proposals[p].voteCount > winningVoteCount) { // see if the vote count for each proposal is more than the winning count
                winningVoteCount = proposals[p].voteCount; // and assign that vote count as the highest to compare recursively with remaining proposals
                winningProposal = p; // after last proposal is counted, the winning proposal is an index to proposals. Use accessor to return proposals[p], or call winnerName()
            }
        }
    }

    function winnerName() public view returns (bytes32 winnerName) { // return the name of the winning proposal using the struct index returned by winningProposal() 
        winnerName = proposals[winningProposal()].name;
    }
    
}