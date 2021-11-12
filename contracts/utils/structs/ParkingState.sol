//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

library ParkingState {
    struct State {
        uint32 freeSpots;
        uint32 occupiedSpots;
    }
}
