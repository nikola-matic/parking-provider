//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../parking/ParkingSpot.sol";

interface IParkingProvider {
    function createParkingSpot() external;

    function destroyParkingSpot() external;

    function acquireSpot() external;

    function releaseSpot() external;

    function getParkingSpots() external view returns (ParkingSpot[] memory);

    function getParkingState()
        external
        view
        returns (Data.ParkingState memory);
}
