// blind_auction.sol

pragma solidity ^0.4.11;

contract BlindAuction { // NOTE: rework openbid template and let blind auction inherit 
    struct Bid { // hold the hashed bid and deposit 
        bytes32 blindedBid; // hashed bid
        uint deposit; // initial deposit
    }

    address public beneficiary; // 
    uint public biddingEnd; // 
    uint public revealEnd; // 
    bool public ended; // flag for auction-is-closed

    mapping(address => Bid[]) public bids; // hold all bids in a mapping, one that uses an address to lookup the right bid struct in an array of Bid structs

    address public highestBidder; // address for the highest bidder 
    uint public highestBid; // amount of the highest bid

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns; // hold returned bid funds in a mapping, one that uses an address to look up the amount to be returned

    event AuctionEnded(address winner, uint highestBid); // notification of event ending with winner and highest bid variables returned 

    /// Modifiers are a convenient way to validate inputs to
    /// functions. `onlyBefore` is applied to `bid` below:
    /// The new function body is the modifier's body where
    /// `_` is replaced by the old function body.
    modifier onlyBefore(uint _time) { require(now < _time); _; } // set a constraint on when bid() and reveal() can be called
    modifier onlyAfter(uint _time) { require(now > _time); _; } // set a constraint on when reveal() and auctionEnd() can be called

    function BlindAuction( // initialize the auction
        uint _biddingTime, 
        uint _revealTime,
        address _beneficiary
    ) public {
        beneficiary = _beneficiary; // set presumably by the contract owner or someone they're working on behalf of
        biddingEnd = now + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
    }

    /// Place a blinded bid with `_blindedBid` = keccak256(value,
    /// fake, secret).
    /// The sent ether is only refunded if the bid is correctly
    /// revealed in the revealing phase. The bid is valid if the
    /// ether sent together with the bid is at least "value" and
    /// "fake" is not true. Setting "fake" to true and sending
    /// not the exact amount are ways to hide the real bid but
    /// still make the required deposit. The same address can
    /// place multiple bids.
    function bid(bytes32 _blindedBid)
        public
        payable
        onlyBefore(biddingEnd)
    {
        bids[msg.sender].push(Bid({ // add a new Bid struct to the bids array using the sender's address as a lookup key.
            blindedBid: _blindedBid, 
            deposit: msg.value
        }));
    }

    /// Reveal your blinded bids. You will get a refund for all
    /// correctly blinded invalid bids and for all bids except for
    /// the totally highest.
    function reveal(
        uint[] _values,
        bool[] _fake,
        bytes32[] _secret
    )
        public
        onlyAfter(biddingEnd) // create a time span that governs the contract's operations
        onlyBefore(revealEnd)
    {
        uint length = bids[msg.sender].length; // sender's number of reported bids
        require(_values.length == length); // make sure the number of blinded bids matches the sender's number of reported bids
        require(_fake.length == length); // 
        require(_secret.length == length); //

        uint refund;
        for (uint i = 0; i < length; i++) { // for all bids from this sender
            var bid = bids[msg.sender][i]; // find each bid
            var (value, fake, secret) = // load each of the reported values 
                    (_values[i], _fake[i], _secret[i]);
            if (bid.blindedBid != keccak256(value, fake, secret)) { // make sure the hashed bid is equal to what's being reported
                // Bid not revealed. 
                // Do not refund deposit.
                continue; // move on to next bid in this bidder's list of bids
            }
            refund += bid.deposit; // keep track of the total refund for this bidder 
            if (!fake && bid.deposit >= value) { // check if there is no fake and the deposit is higher than the value
                if (placeBid(msg.sender, value)) // if placeBid returns true...i.e., the bid is the highest and is accepted
                    refund -= value; // subtract the value of this bid from the bidder's total refund
            }
            // Make it impossible for the sender to re-claim the same deposit.
            bid.blindedBid = bytes32(0); // this bid's blinded bid is set to 0 so that the hashed value will always return 0 if this function were called again
        }
        msg.sender.transfer(refund); // after calculating all refunds and deducting the highest bid (if successful), return all deposits...user will 
        // still need to call withdraw() if their highest bid was superseeded by another highest bidder.
    }

    // This is an "internal" function which means that it
    // can only be called from the contract itself (or from
    // derived contracts).
    function placeBid(address bidder, uint value) internal
            returns (bool success)
    {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != 0) {
            // Refund the previously highest bidder.
            pendingReturns[highestBidder] += highestBid; // look up the highest bidder's address and assign the value of their high bid for refund 
        }
        highestBid = value; // reset the highest bid 
        highestBidder = bidder; // and the bidder address
        return true;
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public {
        uint amount = pendingReturns[msg.sender]; // lookup the bidder's refund amount by their address
        if (amount > 0) { // if there's something to return
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `transfer` returns (see the remark above about
            // conditions -> effects -> interaction).
            pendingReturns[msg.sender] = 0; // is it possible to destroy wealth by accidentally setting one of the contract's bidder credits to 0?

            msg.sender.transfer(amount); // send the refund
        }
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd()
        public
        onlyAfter(revealEnd)
    {
        require(!ended); // function can only be called once
        AuctionEnded(highestBidder, highestBid); // alert others that the auction is closed
        ended = true; // set the has-ended flag
        beneficiary.transfer(highestBid); // and send the money
    }
}