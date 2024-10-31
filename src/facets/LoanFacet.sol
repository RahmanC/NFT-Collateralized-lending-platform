// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libraries/LibDiamond.sol";
import "./PausableModifier.sol";

contract LoanFacet is ReentrancyGuard, PausableModifier {
    event LoanCreated(uint256 indexed loanId, address indexed borrower, address indexed lender, uint256 amount);
    event LoanRepaid(uint256 indexed loanId);
    event LoanDefaulted(uint256 indexed loanId);
    
    function createLoan(
        uint256 _escrowId,
        uint256 _interest,
        uint256 _duration
    ) external payable nonReentrant whenNotPaused returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        
        LibDiamond.EscrowData storage escrow = ds.escrows[_escrowId];
        require(escrow.active, "Escrow not active");
        require(escrow.loanId == 0, "Escrow already has loan");
        
        ds.loanCounter++;
        uint256 loanId = ds.loanCounter;
        
        ds.loans[loanId] = LibDiamond.LoanData({
            borrower: escrow.owner,
            lender: msg.sender,
            amount: msg.value,
            interest: _interest,
            duration: _duration,
            startTime: block.timestamp,
            escrowId: _escrowId,
            active: true,
            defaulted: false,
            repaid: false
        });
        
        escrow.loanId = loanId;
        
        // Transfer loan amount to borrower
        payable(escrow.owner).transfer(msg.value);
        
        emit LoanCreated(loanId, escrow.owner, msg.sender, msg.value);
        
        return loanId;
    }
    
    function repayLoan(uint256 _loanId) external payable nonReentrant whenNotPaused {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        LibDiamond.LoanData storage loan = ds.loans[_loanId];
        
        require(loan.active, "Loan not active");
        require(!loan.repaid, "Loan already repaid");
        require(!loan.defaulted, "Loan is defaulted");
        require(msg.sender == loan.borrower, "Not loan borrower");
        
        uint256 totalRepayment = loan.amount + loan.interest;
        require(msg.value >= totalRepayment, "Insufficient repayment");
        
        loan.repaid = true;
        loan.active = false;
        
        // Transfer repayment to lender
        payable(loan.lender).transfer(totalRepayment);
        
        // If there's any excess payment, return it to borrower
        if (msg.value > totalRepayment) {
            payable(msg.sender).transfer(msg.value - totalRepayment);
        }
        
        // Release the NFT back to borrower
        LibDiamond.EscrowData storage escrow = ds.escrows[loan.escrowId];
        IERC721(escrow.nftContract).transferFrom(address(this), loan.borrower, escrow.tokenId);
        
        emit LoanRepaid(_loanId);
    }

    function getLoan(uint256 _loanId) external view returns (LibDiamond.LoanData memory) {
        return LibDiamond.diamondStorage().loans[_loanId];
    }

    // For testing purposes only - in production this would be controlled by admin
    function setLoanAsDefaulted(uint256 _loanId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        LibDiamond.LoanData storage loan = ds.loans[_loanId];
        loan.defaulted = true;
        emit LoanDefaulted(_loanId);
    }
}