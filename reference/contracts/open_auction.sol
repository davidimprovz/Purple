// open auction.sol

pragma solidity ^0.4.11;
	
contract SimpleAuction {
    /* 
    Auction contract params:
    • beneficiary
    • auction end
    • high bidder
    • high bid
    • bid returns
    • ended status
    */
    

    address public beneficiary; // someone gets the money, presumably the one who instantiates the contract
    uint public auctionEnd; //Times are either absolute unix timestamps (seconds since 1970-01-01) or time periods in seconds.

    address public highestBidder; // whois bidder state
    uint public highestBid; // whatis bid state

    mapping(address => uint) pendingReturns; // sets which accounts can withdraw bid money 

    bool ended; // Prevent changes. Set to true when bid time expires. 

    
    event HighestBidIncreased(address bidder, uint amount); // allow bidders to listen for changes. Any decent bid program markets bid changes loudly.
    event AuctionEnded(address winner, uint amount); // notify of ending ...
    // IMPROVEMENT: implement a counter on a website and use that service to call the contract.

    
    // natspec comment...outputs function definition and params via JSON as a help to consumers and devs. 

    /// Create a simple auction with `_biddingTime`
    /// seconds bidding time on behalf of the
    /// beneficiary address `_beneficiary`.
    function SimpleAuction( // constructor function 
        uint _biddingTime, // argument 1 is timedelta 
        address _beneficiary // argument 2 is intended beneficiary...really nice that there's no ambiguity. This could be useful for wills too.
    ) public {
        beneficiary = _beneficiary; // set the benefciary 
        auctionEnd = now + _biddingTime; // set the bid time to current UTC + passed timedelta (in seconds)
    }


    // natspec: tell the bidder that they are sending real money with this transaction (i.e., message)
    // and make sure the refund policy is explicit. Automating contract policies could be useful, as would 
    // some standardization, mapping legal speak to outcomes. 

    /// Bid on the auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    function bid() public payable { // function to handle individual bidding...'payable' is required for the function to be able to receive Ether.
        // Why not provide access to a simple storage contract that allows individuals to pool resources and bid collectively?
        // Or allow an account fiduciary who has a collection of addresses to bid on behalf of his investors?
        // How can fiduciaries easily market their services to ethereum holders? 
        
        require(now <= auctionEnd); // Revert the call if the bidding period is over.
        require(msg.value > highestBid); // If the bid is < previous, send money back.

        if (highestBidder != 0) { // make sure there's at least 1 bidder
            
            // Returning money using highestBidder.send(highestBid) is a security risk because it could execute an untrusted contract.
            // It's safer to ask recipients to withdraw their money. 
            // Note: For leftover, unclaimed funds, an explicit policy should handle issues like forfeiture.

            pendingReturns[highestBidder] += highestBid; // make a new reference to the highest bidder and credit how much money they bid
        }
        highestBidder = msg.sender; // set new bidder
        highestBid = msg.value; // set new bid
        HighestBidIncreased(msg.sender, msg.value); // alert a new high bid, who sent it, and how much it is. 
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public returns (bool) { // self-service bid money withdrawl...keep in mind that some (gas)money is lost in the contract transactions.
        uint amount = pendingReturns[msg.sender]; // lookup the amount to be returned using the address of the sender
        if (amount > 0) { // make sure bidder has funds to be returned
            pendingReturns[msg.sender] = 0; // Must set this to zero because recipient can call function again as part of the receiving call before `send` returns.

            if (!msg.sender.send(amount)) { // send the funds and check the status of the send.
                pendingReturns[msg.sender] = amount; //  if the refund fails, just reset the amount owing
                return false; // and withdraw() returns false
            }
        }
        return true; // otherwise, withdraw() returns true
    }

    /// End the auction and send the highest bid 
    /// to the beneficiary.
    function auctionEnd() public { // any(one/contract) can call the end of the auction assuming the time has elapsed
        
        // Structure functions that interact with other contracts (i.e. they call functions or send Ether) into three phases:
            // Phase 1. check conditions
            // Phase 2. perform actions (potentially changing conditions)
            // Phase 3. interact with other contracts
        
        // If these phases are mixed up, the other contract could call back into the current contract and modify the state or cause
        // effects (ether payout) to be performed multiple times.
        
        // If functions called internally include interaction with external contracts, they also have to be considered interaction 
        // with external contracts.

        // 1. Conditions
        require(now >= auctionEnd); // auction must've ended
        require(!ended); // auction still running, i.e., auctionEnd() not yet called

        // 2. Effects
        ended = true; // set an auction-has-closed flag
        AuctionEnded(highestBidder, highestBid); // notify bidders auction stopped, the high bidder, and their bid amount

        // 3. Interaction
        beneficiary.transfer(highestBid); // send the money immediately
        // ? why would we send money here, but require unsuccessful bidders to withdraw their own funds? same issue is presented. 
    }
}