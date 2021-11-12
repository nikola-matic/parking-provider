//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ParkingMetaData} from "./utils/structs/ParkingMetaData.sol";

import "hardhat/console.sol";
import "./IParkingSpot.sol";

contract ParkingSpot is IParkingSpot {
    ParkingMetaData.MetaData internal metaData;

    constructor() {
        metaData = ParkingMetaData.MetaData(false, 0, 0, address(0));
    }

    function acquire(address account) external override {
        metaData.taken = true;
        // solhint-disable-next-line not-rely-on-time,
        metaData.acquireTimestamp = block.timestamp;
        metaData.releaseTimestamp = 0;
        metaData.owner = account;
    }

    function release(address account) external override {
        require(metaData.owner == account, "Only owner may release");

        metaData.taken = false;
        metaData.acquireTimestamp = 0;
        // solhint-disable-next-line not-rely-on-time,
        metaData.releaseTimestamp = block.timestamp;
        metaData.owner = address(0);
    }

    function getMetaData()
        external
        view
        returns (ParkingMetaData.MetaData memory)
    {
        return metaData;
    }
}
