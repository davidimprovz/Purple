/* 

Simple Storage
An example of basic variable storage, courtesy Solidity documentation - https://solidity.readthedocs.io

Lesson: Declare a single variable and use getter and setter methods to recall and change the data.

To call this contract's methods, 

SimpleStorage.set(x)
SimpleStorage.get()

*/

pragma solidity ^0.4.0; // backwards compatability

contract SimpleStorage { // like a class definition in Python
    uint storedData; // only positive numbers of max 256 bytes

    function set(uint x) public { 
        storedData = x;
    }

    function get() public constant returns (uint) {
        return storedData;
    }
}
