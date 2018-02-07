pragma solidity ^0.4.6;

/* ©2018 David Williams. All Rights Reserved.

Geomanage: A DEMO contract governing a specific geographical area 
(i.e., polygon boundary).

This is a work-in-progress exercise in managing tranactions based 
on geographical boundaries with automatic payment processing for 
use of the contract.

Use: Any time an ioT device georefrences a boundary, a search will 
recall contract terms and the costs governing that parcel. The 
transaction required for operating within the boundary will be paid 
automatically once contract conditions are met and verified.
*/

// THINGS TO IMPLEMENT 
// keyword now
// use of flags to close a contract's operation 
// msg.value money container
// keccak256(value, fake, secret), ethereum's standard hashing encryption
// withdrwaw pattern
// Name enum {}...Name name


contract GeoManage {

	/* 
	Variables
		* admin - contract admin with special privileges
		* funds - eth balance of the contract
		* gas_price - base gas price for using this contract
		* cost - base price for using this contract
	*/

	address admin; // contract admin
	uint funds; // funds held by contract
	uint public cost; // eth cost of using this contract..paid on per-boundary basis
	uint public gas_price; // gas price for contract

	struct Boundary { // container for each boundary
	    address owner;
		string title; // arbitrary name of boundary
		uint[] lat_coords; // dynamic array of lat points
		uint[] lon_coords; // dynamic array of lat points
		uint price; // price for crossing boundary
		bool in_service; // flag for the boundary's in-use (i.e., must be paid) status.
	}

    mapping (address => Boundary) boundaries; // map boundaries to an address
    Boundary[] public geomaps; // dynamic array of all tracked boundaries
    
    // to do: create container to hold all geomaps indexed by address

	// EVENTS 
	event BalanceUpdate(); // notify if contract balance should be emptied
	event IsInside(/*should include UTC time, geolocation, and address*/); // notify when inclusive boundary condition met
	event PriceChange(/*boundary name, price, and date/time for change*/); // notify when boundary price changed
	event BoudnaryCrossing(/* title, time, cost */); // notify when boundary is crossed
	event BoundaryAdded(/* struct Boundary */); // notify when boundary added 
	event BoundaryInvalid(/* title, owner */) // notify when boundary found invalid

	// MODIFIERS
	modifier onlyAdmin(address _address) { require(_address == admin); _; }
	modifier conditional(bool _condition) { require(_condition == true); _; }

	// FUNCTIONS

	/// geoManage() constructor sets the administrator for 
	/// this contract instance. 
	/// To initialize, include the base cost and gas price 
	/// (in wei) of using the as well as the base gas price (in wei). 
	function geoManage(uint _cost, uint _gas_price) public returns (bool)
	{
		require(admin != msg.sender);	
		admin = msg.sender;
		cost = _cost; // contract's base price…assumes some pricing model
		gas_price = _gas_price;
		return true;
	}

	/// addBoundary() takes a price, title, lat/lon points, and
	/// operational status of the proposed boundary.
	/// Will return true when boundary added. To poll your boundaries, use 
	/// viewBoundaries().
	function addBoundary(
	    string _title, // arbitray title for reference
	    uint _price, // the price in wei associated w/ this boundary
	    uint[] _lat_coords, // boundary lat / lon coordinates
	    uint[] _lon_coords,
	    bool _status // operational status…i.e., will customer be charged or not
	)
	    // to do: make payable
		public 
		returns (bool) 
	{
	    // to do: temp holding bin for funds
	    
	    require(_lat_coords.length == _lon_coords.length); // check arrays are same length
	    // to do: add a func to check boundary is valid geo boundary.
	    
        Boundary storage bounds;
        bounds.owner = msg.sender; // sender needs privileges to add boundary
        bounds.title = _title;
        bounds.lat_coords = _lat_coords; 
        bounds.lon_coords = _lon_coords;
        bounds.price = _price;
        bounds.in_service = _status;
        
        // add the boundary to the boundaries array
		boundaries[msg.sender] = bounds;
		
		// to do: enable multiple boundaries per each address
		
        // push the boundary onto the stack of all tracked boundaries 
        geomaps.push(bounds);
        
        //to do: fire a boundary added event
        
        //to do: add value to contract
        
        // to do: if check to make sure boundary is legit, e.g., 
        // if (isLegit(boundary) == true) { return true; }
        // else { return false; }

        return true;
	}
	
	///set the payable status of a boundary
	function setBoundaryStatus(string _title) public returns (bool) {
	    //to do: find boundary by indexing the _title
	    return true;
	} 

// below not tested

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
		// conditional(msg.value >= cost) for crossing the boundary
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

		uint money = funds; 
		funds = 0; // set balance to 0

		// notify admin of balance transfer just in case

		if(!owner.send(this.balance)){ // make sure money gets transferred or revert the transaction 
			funds = money;
			return false;
		}

		return true;
	} 

	// USEFUL SNIPPETS
/*
modifier noReentrancy() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }
*/
}