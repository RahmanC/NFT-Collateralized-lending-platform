// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibDiamond.sol";

contract PausableModifier {
    modifier whenNotPaused() {
        require(!LibDiamond.diamondStorage().paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {
        require(LibDiamond.diamondStorage().paused, "Contract is not paused");
        _;
    }
}