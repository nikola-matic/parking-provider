//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ParkingState} from "../utils/structs/ParkingState.sol";

import "hardhat/console.sol";
import "./ParkingSpot.sol";
import "../utils/access/ParkingAccessControl.sol";
import "../interfaces/IParkingProvider.sol";

contract ParkingProvider is IParkingProvider, ParkingAccessControl {
    ParkingSpot[] private parkingSpots;
    ParkingState.State private parkingState;

    constructor() ParkingAccessControl() {
        parkingState = ParkingState.State(0, 0);
    }

    function createParkingSpot() external override onlyMinter {
        parkingSpots.push(new ParkingSpot());
        parkingState.freeSpots += 1;
    }

    function destroyParkingSpot()
        external
        override
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
        override
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

    function getParkingSpots()
        external
        view
        override
        returns (ParkingSpot[] memory)
    {
        return parkingSpots;
    }

    function getParkingState()
        external
        view
        override
        returns (ParkingState.State memory)
    {
        return parkingState;
    }
}
