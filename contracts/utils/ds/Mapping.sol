//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
 * @dev Mapping library providing a wrapper around mapping(address => uint256),
 * allowing checks regarding a key's existence, removal of elements, etc.
 * @author nikola-matic
 */
library Mapping {
    // Value type for mapping, including a mask used to indicate
    // whether the value for a specified key was previously set.
    // This allows us to differentiate between default (zero) initalized
    // values and once where the actual value was explicitly set as zero.
    // Mask is of uint256 type, as this is more efficient than using a
    // boolean value which requires an extra SLOAD operation
    struct Uint {
        uint256 mask;
        uint256 value;
    }

    // Mask indicator that value was not previously set
    uint256 private constant NOT_SET = 0;
    // Mask indicator that value has already been set
    uint256 private constant SET = 1;

    /**
     * @dev Allows insertion of a key value pair, whilst returning an indicator
     * whether previous value was replaced or not.
     * @param self reference to mapping
     * @param key key to insert
     * @param value value to associate with above key
     * @return replaced whether value was replaced or not
     */
    function insert(
        mapping(address => Uint) storage self,
        address key,
        uint256 value
    ) internal returns (bool replaced) {
        if (self[key].mask == NOT_SET) {
            self[key].mask = SET;
            self[key].value = value;
        } else {
            self[key].value = value;
            return true;
        }

        return false;
    }

    /**
     * @dev Check whether key exists in mapping
     * @param self reference to mapping
     * @param key key to check existence of
     * @param exists indicator whether key exists
     */
    function contains(mapping(address => Uint) storage self, address key)
        internal
        view
        returns (bool exists)
    {
        return self[key].mask == SET;
    }

    /**
     * @dev Get value for given key
     * @param self reference to mapping
     * @param key key for which to fetch value
     * @return value for associated key
     * @notice will throw if key doesn't exist
     */
    function get(mapping(address => Uint) storage self, address key)
        internal
        view
        returns (uint256 value)
    {
        require(contains(self, key), "Key not found");
        return self[key].value;
    }

    /**
     * @dev Erase key and value pair
     * @param self reference to mapping
     * @param key key to erase
     * @return erased indicator of whether values was erased
     */
    function erase(mapping(address => Uint) storage self, address key)
        internal
        returns (bool erased)
    {
        if (contains(self, key)) {
            delete self[key];
            return true;
        }
        return false;
    }
}
