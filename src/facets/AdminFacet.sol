// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDiamondProxy {
    function updateFacet(bytes4 selector, address facetAddress) external;
}

contract AdminFacet {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function updateFacet(bytes4 _selector, address _facetAddress) external onlyOwner {
        require(_facetAddress != address(0), "Invalid facet address");
        IDiamondProxy(address(this)).updateFacet(_selector, _facetAddress);
    }
}
