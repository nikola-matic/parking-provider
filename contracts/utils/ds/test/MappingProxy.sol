//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../Mapping.sol";

/**
 * @dev Proxy contract for testing the Mapping library. In cases of non view/pure
 * function calls (e.g. indicating whether an element was replaced during insertion),
 * events are emitted, as such function will return the TX response instead to the
 * off-chain caller instead of whatever the defined return value type on-chain is.
 */
contract MappingProxy {
    using Mapping for mapping(address => Mapping.Uint);

    mapping(address => Mapping.Uint) private mappingInstance;

    event Inserted();
    event Replaced();
    event Erased();
    event NotErased();

    function insert(address key, uint256 value) external {
        if (mappingInstance.insert(key, value)) {
            emit Replaced();
        } else {
            emit Inserted();
        }
    }

    function contains(address key) external view returns (bool exists) {
        return mappingInstance.contains(key);
    }

    function get(address key) external view returns (uint256 value) {
        return mappingInstance.get(key);
    }

    function erase(address key) external {
        if (mappingInstance.erase(key)) {
            emit Erased();
        } else {
            emit NotErased();
        }
    }
}
