//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ParkingState} from "../utils/structs/ParkingState.sol";

import "hardhat/console.sol";
import "./ParkingSpot.sol";
import "../utils/access/ParkingAccessControl.sol";

contract ParkingProvider is ParkingAccessControl {
    ParkingSpot[] private parkingSpots;
    ParkingState.State private parkingState;

    constructor() ParkingAccessControl() {
        parkingState = ParkingState.State(0, 0);
    }

    function createParkingSpot() external onlyMinter {
        parkingSpots.push(new ParkingSpot());
        parkingState.freeSpots += 1;
    }

    function destroyParkingSpot()
        external
        onlyBurner
        ifSpotExists(parkingSpots)
        ifSpotAvailable(parkingState)
    {
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
                parkingSpots[i].acquire();
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
