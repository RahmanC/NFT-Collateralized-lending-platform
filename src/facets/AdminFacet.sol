// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibDiamond.sol";
import "./PausableModifier.sol";

contract AdminFacet is PausableModifier {
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event Paused(address account);
    event Unpaused(address account);
    
    modifier onlyOwner() {
        require(msg.sender == LibDiamond.diamondStorage().owner, "Not owner");
        _;
    }
    
    modifier onlyAdmin() {
        require(LibDiamond.diamondStorage().admins[msg.sender], "Not admin");
        _;
    }
    
    function addAdmin(address _admin) external onlyOwner {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.admins[_admin] = true;
        emit AdminAdded(_admin);
    }
    
    function removeAdmin(address _admin) external onlyOwner {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(_admin != ds.owner, "Cannot remove owner");
        ds.admins[_admin] = false;
        emit AdminRemoved(_admin);
    }
    
    function pause() external onlyAdmin whenNotPaused {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.paused = true;
        emit Paused(msg.sender);
    }
    
    function unpause() external onlyAdmin whenPaused {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.paused = false;
        emit Unpaused(msg.sender);
    }
}