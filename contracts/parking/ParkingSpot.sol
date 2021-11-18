//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {Data} from "../utils/structs/Data.sol";

import "hardhat/console.sol";
import "../interfaces/IParkingSpot.sol";
import "../utils/access/ParkingAccessControl.sol";

/**
 * @dev Parking spot allows the caller to acquire and release it,
 * while maintaining current data relating to it, such as address
 * of current owner, timestamps of acquire/releases, etc.
 * ParkingSpots are created and managed by ParkingProvider.
 */
contract ParkingSpot is IParkingSpot, ParkingAccessControl {
    Data.ParkingMetaData internal metaData;

    constructor() {
        // Default initialize metadata
        metaData = Data.ParkingMetaData(false, 0, 0, address(0));
    }

    /**
     * @dev Acquire parking spot by setting it as taken, and storing
     * the current timestamp, and owner.
     */
    function acquire() external override {
        metaData.taken = true;
        // solhint-disable-next-line not-rely-on-time
        metaData.acquireTimestamp = block.timestamp;
        metaData.releaseTimestamp = 0;
        metaData.owner = msg.sender;
    }

    /**
     * @dev Release parking spot back into circulation. Sets taken status
     * to false, and release time to current timestamp, in addition to
     * resetting ownership. Can be called by owner only, i.e whoever
     * acquired the spot initially.
     * @notice Will throw if called by non-owner
     */
    function release() external override ifOwnerOfSpot(this) {
        metaData.taken = false;
        metaData.acquireTimestamp = 0;
        // solhint-disable-next-line not-rely-on-time
        metaData.releaseTimestamp = block.timestamp;
        metaData.owner = address(0);
    }

    /**
     * @dev Gettet for spot's internal meta data (state)
     * @return internal meta data
     */
    function getMetaData()
        external
        view
        returns (Data.ParkingMetaData memory)
    {
        return metaData;
    }
}
