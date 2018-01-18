/* 

©2018 David Williams. All Rights Reserved. 

Geomanage: A contract governing a specific geographical area (i.e., polygon boundary).

An exercise in managing tranactions based on geographical boundaries with automatic 
payment processing for use of the service.

Use: Any time a ioT device georefrences the boundary specified within each contract instantiation, 
a search will recall contract terms and the costs governing that parcel. The transaction required 
for operating within the boundary will be paid automatically once contract conditions are met.

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

contract GeoManage {
	/* 
	Variables instantiated include:
	• admin - contract admin with special privileges
	• balance - funds the contract owns
	• cost - price to use the boundary
	• boundary / boundaries - specific boundaries and a container for all of them.
	*/

	address admin; // contact admin
	uint balance; // contract balance .. only set by admin 
	uint public cost = 0; // eth cost of using this service initialized to 0

	struct boundary { // container for each boundary
		string name; // arbitrary name of boundary
		uint[][] geospatial_points; // a 1x2 container of lat/long points that form the boundary polygon (dynamically allocated).
		bool is_available; // flag for the boundary's pay-for / in-use status. 
	}

	boundary[] public boundaries; // an array of boundary structs

	event BalanceUpdate(); // notify if contract balance should be moved to an account
	event IsInside(); // notify when inclusive boundary condition met...should include UTC time, geolocation, and address
	event PriceChange(); // notify when price changed

	function geoManage(
		uint price, 
		string title, 
		uint[][] bounds
	) 
		public 
	  	payable // money can be sent into contract via this constructor 
	{ // constructor sets boundary admin for this contract
		admin = msg.sender;
		cost = price;
		// need for loop to push new boundary structs onto the boundaries array.
			// push
	}


	function crossBoundary(uint payment, string service, uint location) public returns (string, uint) { // primary function 
		// receives a price for crossing the threshold, a service name, and a GPS-fixed location
		
		// storage within functions for global shorthand references
		
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
		// storage within functions for global shorthand references
		require(msg.sender != admin);
		cost = price;
	}


	function sendBalance(uint money) returns(address, uint) {
		// storage within functions for global shorthand references
		require(msg.sender != admin); // unnecessary but check in case it's possible to access non-public methods
		// process balance transfer
		return 1;
	}
}


// create event for boundary crossed

// create event for sending balance to account
	// fire sendBalance(balance)

// create event to notify of price change