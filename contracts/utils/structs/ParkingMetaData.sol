//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

library ParkingMetaData {
    struct MetaData {
        bool taken;
        uint256 acquireTimestamp;
        uint256 releaseTimestamp;
        address owner;
    }
}
