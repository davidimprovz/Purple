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


// keyword now
// use of flags to close a contract's operation 
// msg.value money container
// keccak256(value, fake, secret), ethereum's standard hashing encryption



pragma solidity ^0.4.0;

contract GeoManage {
	
	// VARIABLES

	/* 
	Variables instantiated include:
	• admin - contract admin with special privileges
	• balance - funds the contract owns
	• cost - price to use the boundary
	• boundary / boundaries - specific boundaries and a container for all of them.
	*/

	address admin; // contract admin
	uint balance; // contract balance set by admin
	uint public cost; // eth cost of using this service...currently paid on a per-boundary basis
	uint public gas_price; // gas price for contract

	struct boundary { // container for each boundary
		string name; // arbitrary name of boundary
		uint[][] geospatial_points; // a 1x2 container of lat/long points that form a boundary polygon (dynamically allocated).
		bool in_service; // flag for the boundary's pay-for / in-use status. 
	}

	boundary[] public boundaries; // an array of boundary structs
	mapping (address => boundaries); // a collection of boundaries is found using an address


	// EVENTS 
	event BalanceUpdate(); // notify if contract balance should be emptied ... 
	event IsInside(); // notify when inclusive boundary condition met...should include UTC time, geolocation, and address
	event PriceChange(); // notify when price changed


	// MODIFIERS
	modifier onlyAdmin(address _address) { require(_address == admin); _; }


	// FUNCTIONS

	/// geoManage() constructor sets the administrator for this instance of 
	/// geo management.
	function geoManage(address _address) public returns (bool)
	{
		if(!admin && !cost){
			admin = msg.sender;
			cost = price;
			return true;
		} 

		else { return false; }
	}


	/// addBoundary() takes a price, title, and geoboundaries to manage.
	/// Will return true when boundary added. To poll your boundaries, use 
	/// viewBoundaries().
	function addBoundary(uint _payment, struct _boundary) 
		public 
		payable // money can be sent into contract via this constructor 
		returns (bool)
	{
		// pay first
		// 

		boundaries[msg.sender].push(_boundary);

	}



	/// viewBoundaries() returns a list of your boundary titles.  
	function viewBoundaries(address _whois) public returns (string[]){
		// make sure there are actually boundaries for this account
		// call up boundaries and return list
		// loop through list and get titles for each
		// return array of titles
		return true; // placeholder 
	}


	/// TBD
	function crossBoundary ( // primary function 
		uint payment, 
		string service, 
		uint location
	) 
		public 
		returns (string, uint) 
	{ 
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


	// reset gas price as needed
	function updateGasPrice() internal returns(uint) {
		// search for gas price changes
		return cost;
	}


	// setCost() periodically sets the cost of calling the contract
	function setCost(uint _cost) public onlyAdmin(msg.sender) returns(bool) {
		// check for gas cost changes 
		gas = updateGasPrice(); // no need to check for price change...just update and notifiy
		gas_price = gas;
		PriceChange(_cost, gas_price); // fire event to notify price has change 
		cost = _cost; // change the cost of the contract 
		
		return true;
	}


	// sendBalance() transfers funds held by contract to the administrator's designated account
	function sendBalance(address _address) public onlyAdmin(msg.sender) returns(bool) {
		// check if alternate address requested 
		if(msg.sender == _address){ destination = msg.sender; } 
		else{ destination = _address; }

		uint money = balance; // hold money 
		balance = 0; // set balance to 0

		// notify admin of balance transfer just in case

		if(!owner.transfer(money)){ // make sure money gets transferred or revert the transaction 
			balance = money;
			return false;
		}

		return true;
	} 

}