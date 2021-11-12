//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ParkingState} from "./utils/structs/ParkingState.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";
import "hardhat/console.sol";
import "./ParkingSpot.sol";
import "./utils/access/ParkingAccessControl.sol";

contract ParkingProvider is AccessControl, ParkingAccessControl {
    ParkingSpot[] private parkingSpots;
    ParkingState.State private parkingState;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);

        parkingState = ParkingState.State(0, 0);
    }

    function createParkingSpot() external {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "Only minter may create spot"
        );
        parkingSpots.push(new ParkingSpot());
        parkingState.freeSpots += 1;
    }

    function destroyParkingSpot()
        external
        ifSpotExists(parkingSpots)
        ifSpotAvailable(parkingState)
    {
        require(
            hasRole(BURNER_ROLE, msg.sender),
            "Only burner may destroy spot"
        );

        uint256 parkingSize = parkingSpots.length;

        for (uint256 i = 0; i < parkingSize; ++i) {
            if (!parkingSpots[i].getMetaData().taken) {
                parkingSpots[i] = parkingSpots[parkingSize - 1];
                parkingSpots.pop();
                parkingState.freeSpots -= 1;
                break;
            }
        }
    }

    function acquireSpot()
        external
        ifSpotExists(parkingSpots)
        ifSpotAvailable(parkingState)
    {
        for (uint256 i = 0; i < parkingSpots.length; ++i) {
            if (!parkingSpots[i].getMetaData().taken) {
                parkingSpots[i].acquire(msg.sender);
                parkingState.freeSpots -= 1;
                parkingState.occupiedSpots += 1;
                break;
            }
        }
    }

    function getParkingSpots() external view returns (ParkingSpot[] memory) {
        return parkingSpots;
    }

    function getParkingState()
        external
        view
        returns (ParkingState.State memory)
    {
        return parkingState;
    }
}
