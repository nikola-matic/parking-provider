//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IParkingSpot {
    function acquire(address account) external;

    function release(address account) external;
}
