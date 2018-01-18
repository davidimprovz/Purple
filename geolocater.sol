/* 
©2018 David Williams. All Rights Reserved. 

Geolocate: An exercise in managing tranactions based on geographical boundaries with 
automatic payment processing for use of the service.

Use: Send a geolocation through FindBoundary() and it is processed to determine if a point lies 
within a reference boundary. Useful for tracking sales zones, delivery of goods, etc.

The user may select the desired geolocator when calling FindBoundary. Current options include: 
	* ArcGIS, 
	* Google,
	* OpenCage 

*/

// msg.sender.send
// _argument with same name as class variable function(){ argument = _argument; }
// keyword now
// .transfer()
// payable keyword
// fire events
// use of flags to close a contract's operation 
// modifier keyword
// array[address].push()
// msg.value money container
// keccak256(value, fake, secret), ethereum's standard hashing encryption
// internal keyword for functions


pragma solidity ^0.4.0;

contract GeoLocate { // to find locations 

	
	address admin; // contact admin 
	uint balance; // contract balance .. only set by admin 
	uint public cost = 0 ; // eth cost of using this service initialized to 0


	

	// notify if contract balance should be moved to an account
	event BalanceUpdate();
	// notify when inclusive boundary condition met
	event IsInside(); // should include UTC time, geolocation, and address
	// notify when price changed
	event PriceChange();


	// constructor sets contract admin
	function geoLocateBoundary(uint price) public {
		admin = msg.sender;
		cost = price;
	}


	function crossBoundary(uint payment, string service, uint location) public returns (string, uint) { // primary function 
		// receives a price for crossing the threshold, a service name, and a GPS-fixed location
		
		require(payment != cost); // do nothing if price not paid

		// update balance status
		// fire balance transfer

		// use msg.value to call variables passed into function ?

		// select a service with instantiation
		// pass GPS location to service that checks for and retrieves boundary polygons (e.g., uint [])
		// pass JSON to selected geolocator API
		// get geolocation result 
		// send json geolocation result to GIS API to determine inclusion / exclusion and proximity / distance
		// fire event if inclusive
		// otherwise return a notice of exclusion and boundary proximity

		// register errors and reverse transaction
	}


	// set the cost of calling the contract
	function setCost(uint price) public {
		require(msg.sender != admin);
		cost = price;
	}


	function sendBalance(uint money) returns(address, uint) {
		require(msg.sender != admin); // unnecessary but check in case it's possible to access non-public methods
		// process balance transfer
		return 1;
	}
}


// create event for boundary crossed

// create event for sending balance to account
	// fire sendBalance(balance)

// create event to notify of price change