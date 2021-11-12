//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ParkingState} from "../structs/ParkingState.sol";

import "../../ParkingSpot.sol";

abstract contract ParkingAccessControl {
    modifier ifSpotExists(ParkingSpot[] memory parkingSpots) {
        require(parkingSpots.length > 0, "No parking spots exist");
        _;
    }

    modifier ifSpotAvailable(ParkingState.State memory parkingState) {
        require(parkingState.freeSpots > 0, "No free parking spots");
        _;
    }
}
