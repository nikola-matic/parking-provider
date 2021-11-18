//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {Data} from "../structs/Data.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../../parking/ParkingSpot.sol";
import "../ds/Mapping.sol";

abstract contract ParkingAccessControl is AccessControl {
    using Mapping for mapping(address => Mapping.Uint);
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);
    }

    modifier ifSpotExists(ParkingSpot[] memory parkingSpots) {
        require(parkingSpots.length > 0, "No parking spots exist");
        _;
    }

    modifier ifSpotAvailable(Data.ParkingState memory parkingState) {
        require(parkingState.freeSpots > 0, "No free parking spots");
        _;
    }

    modifier ifAcquiredSpot(
        mapping(address => Mapping.Uint) storage addressMapping
    ) {
        require(
            addressMapping.contains(msg.sender),
            "Sender has not acquired spot"
        );
        _;
    }

    modifier ifOwnerOfSpot(ParkingSpot parkingSpot) {
        require(
            parkingSpot.getMetaData().owner == msg.sender,
            "Only owner may perform operation"
        );
        _;
    }

    modifier onlyMinter() {
        // solhint-disable-next-line reason-string
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "Only minter may perform operation"
        );
        _;
    }

    modifier onlyBurner() {
        // solhint-disable-next-line reason-string
        require(
            hasRole(BURNER_ROLE, msg.sender),
            "Only burner may perform operation"
        );
        _;
    }

    modifier onlyAdmin() {
        // solhint-disable-next-line reason-string
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Only admin may perform operation"
        );
        _;
    }
}
