//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

library Data {
    struct ParkingMetaData {
        bool taken;
        uint256 acquireTimestamp;
        uint256 releaseTimestamp;
        address owner;
    }

    struct ParkingState {
        uint32 freeSpots;
        uint32 occupiedSpots;
    }
}
