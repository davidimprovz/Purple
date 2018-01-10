/* 

Geolocate: An exercise in managing tranactions based on geographical boundaries with 
automatic payment processing for use of the service.

Use: Send a geolocation through FindBoundary() and it is processed to determine if a point lies 
within a reference boundary. Useful for tracking sales zones, delivery of goods, etc.

The user may select the desired geolocator when calling FindBoundary. Current options include: 
	* ArcGIS, 
	* Google,
	* OpenCage 

*/

pragma solidity ^0.4.0;


contract GeoLocate {

	// contact admin 
	address admin; 
	// contract balance .. only set by admin 
	uint balance;
	// eth cost of using this service
	uint public cost = 1 ; // set ether amount
	

	// notify if contract balance should be moved to an account
	event BalanceUpdate();
	// notify when inclusive boundary condition met
	event IsInside(); // should include UTC time, geolocation, and address
	// notify when price changed
	event PriceChange();


	// constructor sets contract admin
	function GeoLocateBoundary(uint price) public {
		admin = msg.sender;
		cost = price;
	}


	function FindBoundary(uint price, string service, uint location, uint boundary) public returns (string, uint) { // primary function 
		
		if (price != cost) return; // do nothing if price not paid

		// update balance status
		// fire balance transfer

		// use msg.value to call variables passed into function ?

		// select a service with instantiation
		// pass JSON to selected geolocator API
		// get geolocation result 
		// send json geolocation result to GIS API to determine inclusion / exclusion and proximity / distance
		// fire event if inclusive
		// otherwise return a notice of exclusion and boundary proximity

		// register errors and reverse transaction
	}


	// set the cost of calling the contract
	function setCost(uint price) public {
		if (msg.sender != admin) return;
		cost = price;
	}


	function sendBalance(uint money) returns(address, uint) {
		if (msg.sender != admin) return; // unnecessary but check in case it's possible to access non-public methods
		// process balance transfer
		return 1;
	}
}


// create event for boundary crossed

// create event for sending balance to account
	// fire sendBalance(balance)

// create event to notify of price change