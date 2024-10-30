// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DiamondProxy {
    mapping(bytes4 => address) public facets;

    constructor(address _adminFacet) {
        facets[bytes4(keccak256("adminFacet()"))] = _adminFacet;
    }

    function updateFacet(bytes4 selector, address facetAddress) external {
        require(facetAddress != address(0), "Invalid facet address");
        facets[selector] = facetAddress;
    }

    fallback() external payable {
        address facet = facets[msg.sig];
        require(facet != address(0), "Function does not exist");
        
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    
    receive() external payable {}
}
