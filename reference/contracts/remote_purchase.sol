// remote_purchase.sol
pragma solidity ^0.4.11;


/*  
All contracts consist of variables used in tracking data, the functions 
governing the variables before, during, and after the life of the transaction, 
and events that notify interested parties of a contract's status.

Time is the primary independent variable that governs these 
types of contracts. Events and / or conditions must be handled
in the exchange b/t buyer and seller in order to remove risk.
These contracts are an exercise in risk mitigation. In effect, 
the Ethereum system becomes the law and makes people behave.

Note that in this contract, the seller risks losing their escrow if the value of 
the item being sold is underpriced. If so, the buyer has little incentive
to call confirmReceived(). They could simply put up an escrow, 
receive the good, and resell in a market which provided a higher return.
A 3rd party service, such as a shipper, could be party to this contract
and submit a confirmation (e.g., of shipment) that begins a countdown.
*/

contract Purchase {

    /* 
    
    Variables needed for purchase:
    • value
    • seller
    • buyer
    • state - a user-defined tyle consisting of 3 properties: created, locked, inactive

    */

    uint public value; // the value of a thing
    address public seller; // the seller..presumably the one who calls this contract
    address public buyer; 
    enum State { Created, Locked, Inactive } // three states for the thing being sold 
    State public state; // only 1 state per item...initialized automatically to first property of "created"

    // Ensure that `msg.value` is an even number.
    // Division will truncate if it is an odd number.
    // Check via multiplication that it wasn't an odd number.
    function Purchase() public payable { // seller puts up escrow 
        seller = msg.sender;
        value = msg.value / 2; 
        require((2 * value) == msg.value);
    }

    modifier condition(bool _condition) {
        require(_condition); // 
        _;
    }

    modifier onlyBuyer() { 
        require(msg.sender == buyer); // make sure there's only 1 buyer
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller); // make sure there's only one seller
        _;
    }

    modifier inState(State _state) {
        require(state == _state); // make sure that the state of the sale is as reported
        _;
    }

    event Aborted(); // notify sale canceled
    event PurchaseConfirmed(); // notify sale confirmed
    event ItemReceived(); //

    /// Abort the purchase and reclaim the ether.
    /// Can only be called by the seller before
    /// the contract is locked.
    function abort()
        public
        onlySeller // only the seller can call this ... buyer cannot cancel their purchase
        inState(State.Created) // the state has to be "created", and seller cannot abort once the purchase is confirmed.
    {
        Aborted(); // notify the sale is aborted
        state = State.Inactive; // set the state to inactive
        seller.transfer(this.balance); // and return the escrow
    }

    /// Confirm the purchase as buyer.
    /// Transaction has to include `2 * value` ether.
    /// The ether will be locked until confirmReceived
    /// is called.
    function confirmPurchase()
        public
        inState(State.Created) // sale must have been created
        condition(msg.value == (2 * value)) // make sure that the buyer has put up the full amount of money
        payable
    {
        PurchaseConfirmed(); // notify that purchase is ok'd 
        buyer = msg.sender; // set buyer address
        state = State.Locked; // the contract cannot be altered until what was paid for is received
    }

    /// Confirm that you (the buyer) received the item.
    /// This will release the locked ether.
    function confirmReceived()
        public
        onlyBuyer // only the buyer can access this method
        inState(State.Locked) // confirmPurchase() must have been called
    {
        ItemReceived(); // notify the seller that their item was received 
        // It is important to change the state first because
        // otherwise, the contracts called using `send` below
        // can call in again here.
        state = State.Inactive; // make sure the contract is inactive so this payment processor method cannot be double-called.
        // NOTE: This actually allows both the buyer and the seller to
        // block the refund - the withdraw pattern should be used.

        buyer.transfer(value); // send the buyer's escrow back
        seller.transfer(this.balance); // send the contract's balance (i.e., the escrow) back to the seller
    }
}
