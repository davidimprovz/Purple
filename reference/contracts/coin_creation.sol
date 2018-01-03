/*

Subcurrency Creation
An example of creating your own coin, courtesy of Solidity documentation - https://solidity.readthedocs.io 

Lesson: Use a constructor function to assign an admin role and use a mapping to track owner balances.

Coin.mint(receiver, amount)
Coin.send(receiver, amount)

In a real world example, coins would be either (1) attached to a valued physical asset, (2) attached to a service, or (3) a token 
of abstract ownership, such as a stock certificate, with an accompanying legal framework to enforce rights and priviliges. 
In the case of payment for assets, each example benefits from a ledger describing the payment price for the assets, making 
accounting and calculation of ownership percentages an automated, unambiguous task.

Legal frameworks for digital assets are not unlike legal frameworks for any other asset. Coins are new, so you may want to consult a lawyer.

Steptoe & Johnson - https://www.steptoe.com/
Perkins Cole - https://www.perkinscoie.com/
Thompson Hine - http://www.thompsonhine.com/
Goodwin Procter - https://www.goodwinlaw.com/

*/

pragma solidity ^0.4.0;

contract Coin {
    
    address public minter; // address is 160bit w/ no arithmetic allowed 
    // address stores contract addresses or external keypairs.
    // Note: Public variables have an implicit getter method, e.g., Coin.minter() returns Coin.minter

    mapping (address => uint) public balances; // mappins are hash tables of key > value pairs, like a dict in Python.

    event Sent(address from, address to, uint amount); // events fire when called by another function...useful for creating listeners to react (see below)

    function Coin() public { // a constructor...carries same name as the contract, and only fires when the contract is created.
        minter = msg.sender; // set the name of the sender...note that all code is deployed in a message. msg is a special global variable
    }

    function mint(address receiver, uint amount) public { // create the coins
        if (msg.sender != minter) return; // unless you're the one who deployed the contract, nothing happens
        balances[receiver] += amount; // note that the transfers are stored locally, so no blockchain record will show. Use an event handler to push onto the chain.
    }

    function send(address receiver, uint amount) public { // anyone can send coin to anyone else, 
        if (balances[msg.sender] < amount) return; // assuming they have coin to send
        balances[msg.sender] -= amount; 
        balances[receiver] += amount;
        Sent(msg.sender, receiver, amount); 
    }
}


// Add an event listener 
Coin.Sent().watch({}, '', function(error, result) { 
    if (!error) {
        
        console.log("Coin transfer: " + result.args.amount + // use result.args and the arg names set in Sent event declaration
            " coins were sent from " + result.args.from +
            " to " + result.args.to + ".");

        console.log("Balances now:\n" +
            "Sender: " + Coin.balances.call(result.args.from) + // to access balances, use call with the arg name provided in Set event declaration
            "Receiver: " + Coin.balances.call(result.args.to));
    
    } else {
        
        console.log("Error sending coins: " + error);
    
    }
})
