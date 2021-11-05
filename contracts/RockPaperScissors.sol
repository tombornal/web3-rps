// SPDX-License-Identifier UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract RockPaperScissors {
	uint256 totalThrows;

	// we'll use this seed to help with random number gen
	uint256 private seed;
	
	// create an event
	event NewThrow(address indexed from, uint256 user_choice, uint256 contract_choice, uint256 outcome, uint256 timestamp);

	/*
	* This struct is a custom data type that will help later on with the event (?)
	*/

	struct RPSThrow {
		address thrower; // address of user who threw
		uint256 user_choice; // choice of the user
		uint256 contract_choice; // choice of the contract
		uint256 outcome; // outcome of the match
		uint256 timestamp; // timestamp of the throw
	}

	// This variable will store an array of structs (in our case, throws)
	// This lets us hold all throws sent

	RPSThrow[] rpsthrows;

	// storing an address => uint mapping to associate an address to a number
	// for this, it'll be an address and the last time a user threw
	mapping(address => uint256) public userLastThrownAt;
	mapping(address => uint256) public userTotalWins;

	constructor() payable {
		console.log("Look, mom! This is a smart contract for RPS being constructed");
	}

	function rpsThrow(uint256 _choice) public {
		// first check user hasn't thrown in last 10 seconds
		// require(
		// 	userLastThrownAt[msg.sender] + 10 seconds < block.timestamp,
		// 	"Wait 10 seconds between throws plz"
		// );

		// update timestamp for user
		userLastThrownAt[msg.sender] = block.timestamp;

		totalThrows += 1;
		console.log("%s has thrown a %s!", msg.sender, _choice);

		// flag for if user won
		uint256 didwin = 0;

		
		// generate a pseudo random number between 0 and 2, this will be the machine's throw
		uint256 randomNumber = (block.difficulty + block.timestamp + seed) % 3;
		console.log("Rand number generated: %s", randomNumber);

		// Set the generated, random number as the seed for the next machine throw
		seed = randomNumber;

		// Compare throws
		// debug
		// randomNumber = 2;
		// console.log("Overwriting randomNumber to %s", randomNumber);


		console.log("User selection: %s", _choice);
		if (randomNumber == _choice) {
			console.log("It's a draw! You both played %s", _choice);
		} else {
			if (_choice == 0) {
				if (randomNumber == 1) {
					console.log("Paper covers rock. Contract dominates. Humans ngmi");
				} else {
					console.log("Rock smashes scissors, %s pulls off the W!", msg.sender);
					didwin = 1;
				}
			}
			if (_choice == 1) {
				if (randomNumber == 2) {
					console.log("Scissors cut paper. Contract dominates. Humans ngmi");
				} else {
					console.log("Paper covers rock, %s pulls off the W!", msg.sender);
					didwin = 1;
				}
			}
			if (_choice == 2) {
				if (randomNumber == 0) {
					console.log("Rock smashes scissors. Contract dominates. Humans ngmi");
				} else {
					console.log("Scissors cut paper, %s pulls off the W!", msg.sender);
					didwin = 1;
				}
			}
		}

		if (didwin == 1) {
			userTotalWins[msg.sender] += 1;

			// send prize
			uint256 prizeAmount = 0.0001 ether;
			require(
				prizeAmount <= address(this).balance,
				"Trying to withdraw more money than the contract has."
			);
			(bool success, ) = (msg.sender).call{value: prizeAmount}("");
			require(success, "Failed to withdraw money from contract.");
		}

		// store the throw data into the array as a throw struct
		rpsthrows.push(RPSThrow(msg.sender, _choice, randomNumber, didwin, block.timestamp));

		// this emits the event which should store It on the blockchain (?)
		emit NewThrow(msg.sender, _choice, randomNumber, didwin, block.timestamp);
	}

	// this new function will return the struct array, i.e., throws, which makes it easier to retrieve throws
	// rather than just getting the number of throws, we get all the throw details, i.e., sender, choice, timestamp
	function getAllThrows() public view returns (RPSThrow[] memory) {
		return rpsthrows;
	}

	function getTotalThrows() public view returns (uint256) {
		console.log("We have %d total throws!", totalThrows);
		return totalThrows;
	}

}