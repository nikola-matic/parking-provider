//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../Array.sol";

/**
 * @dev Proxy contract for testing the Array library.
 */
contract ArrayProxy {
    using Array for ParkingSpot[];

    ParkingSpot[] private parkingSpotsInstance;

    function insertSpot() external {
        parkingSpotsInstance.push(new ParkingSpot());
    }

    function size() external view returns (uint256) {
        return parkingSpotsInstance.length;
    }

    function erase(uint256 index) external {
        parkingSpotsInstance.erase(index);
    }
}
