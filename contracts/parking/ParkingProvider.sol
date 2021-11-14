//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ParkingState} from "../utils/structs/ParkingState.sol";

import "hardhat/console.sol";
import "./ParkingSpot.sol";
import "../utils/access/ParkingAccessControl.sol";
import "../utils/ds/MappingAddressInt.sol";
import "../interfaces/IParkingProvider.sol";

/**
 * @dev Parking provider contract is the owner of parking spots. It can create,
 * and destroy parking spots; in additionm, it servers as the handler/proxy for
 * parking acquire/release requests from clients.
 */
contract ParkingProvider is IParkingProvider, ParkingAccessControl {
    using Mapping for mapping(address => Mapping.Uint);

    // Array holding all parking spots managed by this provider
    ParkingSpot[] private parkingSpots;
    // Structure holding current state of provider
    ParkingState.State private parkingState;
    // Mapping of users (msg.sender) to their parking spot index (see parkingSpots)
    mapping(address => Mapping.Uint) private mapAddressToIndex;

    constructor() ParkingAccessControl() {
        parkingState = ParkingState.State(0, 0);
    }

    /**
     * @dev Create parking spot and add it to list of spots. Will update
     * internal state accordingly.
     * @notice Can only be called by user with minter role
     */
    function createParkingSpot() external override onlyMinter {
        parkingSpots.push(new ParkingSpot());
        parkingState.freeSpots += 1;
    }

    /**
     * @dev Destroy parking spot and remove it from list of spots. Will update
     * internal state accordingly.
     * @notice Can only be called by user with burner role, and can only destroy
     * a spot if it is not currently taken, and if there are spots available (created)
     */
    function destroyParkingSpot()
        external
        override
        onlyBurner
        ifSpotExists(parkingSpots)
        ifSpotAvailable(parkingState)
    {
        uint256 parkingSize = parkingSpots.length;

        for (uint256 i = 0; i < parkingSize; ++i) {
            if (!parkingSpots[i].getMetaData().taken) {
                parkingSpots[i] = parkingSpots[parkingSize - 1];
                parkingSpots.pop();
                parkingState.freeSpots -= 1;
                break;
            }
        }
    }

    /**
     * @dev Acquire spot will find a free spot and acquire it for the
     * requesting user (msg.sender). Internal state will be updated accordingly.
     * @notice Spot can only be acquire if there are available spots (both created
     * and free/unoccupied)
     */
    function acquireSpot()
        external
        override
        ifSpotExists(parkingSpots)
        ifSpotAvailable(parkingState)
    {
        for (uint256 i = 0; i < parkingSpots.length; ++i) {
            if (!parkingSpots[i].getMetaData().taken) {
                require(
                    !mapAddressToIndex.contains(msg.sender),
                    "Account already assigned"
                );
                mapAddressToIndex.insert(msg.sender, i);
                parkingSpots[i].acquire();
                parkingState.freeSpots -= 1;
                parkingState.occupiedSpots += 1;
                break;
            }
        }
    }

    /**
     * @dev Getter for array of parking spots.
     * @return array of parking spots
     */
    function getParkingSpots()
        external
        view
        override
        returns (ParkingSpot[] memory)
    {
        return parkingSpots;
    }

    /**
     * @dev Getter for current state of parking provider
     * @return parking state
     */
    function getParkingState()
        external
        view
        override
        returns (ParkingState.State memory)
    {
        return parkingState;
    }

    /**
     * @dev Getter for index of acquired spot of requesting user.
     * @notice Will throw if requesting user (msg.sender) does not have an
     * acquired parking spot, i.e. is not in the user => index mapping
     */
    function getParkingId() external view returns (uint256) {
        return mapAddressToIndex.get(msg.sender);
    }
}
