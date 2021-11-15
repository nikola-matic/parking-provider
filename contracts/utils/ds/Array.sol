//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../../parking/ParkingSpot.sol";

/**
 * @dev Array library providing helper methods for easier data management,
 * such as erasing an element via swap, in order to size down the array.
 * @author nikola-matic
 */
library Array {
    /**
     * @dev Erase function, allowing the caller to remove an element at provided
     * index, where the last element in the array will be swapped to the location
     * indexed by index
     * @param self reference to array
     * @param index index of element to erase
     * @notice Will throw if index larger than array length
     */
    function erase(ParkingSpot[] storage self, uint256 index) internal {
        require(self.length > index, "Out of range");
        self[index] = self[self.length - 1];
        self.pop();
    }
}
