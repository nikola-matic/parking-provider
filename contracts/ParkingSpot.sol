//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./IParkingSpot.sol";

contract ParkingSpot is IParkingSpot {
    struct MetaData {
        bool taken;
        uint256 acquireTimestamp;
        uint256 releaseTimestamp;
        address owner;
    }

    MetaData internal metaData;

    constructor() {
        metaData = MetaData(false, 0, 0, address(0));
    }

    function acquire(address account) external override {
        metaData.taken = true;
        metaData.acquireTimestamp = block.timestamp;
        metaData.releaseTimestamp = 0;
        metaData.owner = account;
    }

    function release(address account) external override {
        require(metaData.owner == account, "Only owner may release");

        metaData.taken = false;
        metaData.acquireTimestamp = 0;
        metaData.releaseTimestamp = block.timestamp;
        metaData.owner = address(0);
    }

    function getMetaData() external view returns (MetaData memory) {
        return metaData;
    }
}
