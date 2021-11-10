//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "hardhat/console.sol";
import "./ParkingSpot.sol";

contract ParkingProvider is AccessControl {
    struct ParkingState {
        uint32 freeSpots;
        uint32 occupiedSpots;
    }

    ParkingSpot[] private parkingSpots;
    ParkingState private parkingState;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);

        parkingState = ParkingState(0, 0);
    }

    function createParkingSpot() external {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "Only minter may create spot"
        );
        parkingSpots.push(new ParkingSpot());
        parkingState.freeSpots += 1;
    }

    function destroyParkingSpot() external {
        require(
            hasRole(BURNER_ROLE, msg.sender),
            "Only burner may destroy spot"
        );
        require(parkingSpots.length > 0, "No parking spots to remove");
        require(parkingState.freeSpots > 0, "No unoccupied parking spots");

        uint parkingSize = parkingSpots.length;

        for (uint256 i = 0; i < parkingSize; ++i) {
            if (!parkingSpots[i].getMetaData().taken) {
                parkingSpots[i] = parkingSpots[parkingSize - 1];
                parkingSpots.pop();
                parkingState.freeSpots -= 1;
                break;
            }
        }
    }

    function acquireSpot() external {
        require(parkingSpots.length > 0, "No parking spots to acquire");
        require(parkingState.freeSpots > 0, "No unoccupied parking spots");

        for (uint256 i = 0; i < parkingSpots.length; ++i) {
            if (!parkingSpots[i].getMetaData().taken) {
                parkingSpots[i].acquire(msg.sender);
                parkingState.freeSpots -= 1;
                parkingState.occupiedSpots += 1;
                break;
            }
        }
    }

    function getParkingSpots() external view returns (ParkingSpot[] memory) {
        return parkingSpots;
    }

    function getParkingState() external view returns (ParkingState memory) {
        return parkingState;
    }
}
