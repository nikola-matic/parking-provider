//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IParkingSpot {
    function acquire() external;

    function release() external;
}
