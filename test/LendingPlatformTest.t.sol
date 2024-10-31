// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DiamondProxy.sol";
import "../src/facets/AdminFacet.sol";
import "../src/facets/EscrowFacet.sol";
import "../src/facets/LoanFacet.sol";
import "../src/facets/PriceFacet.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockNFT is ERC721 {
    constructor() ERC721("MockNFT", "MNFT") {}
    
    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

contract LendingPlatformTest is Test {
    DiamondProxy public diamond;
    AdminFacet public adminFacet;
    EscrowFacet public escrowFacet;
    LoanFacet public loanFacet;
    PriceFacet public priceFacet;
    MockNFT public mockNFT;
    
    address public owner = address(this);
    address public borrower = address(0x1);
    address public lender = address(0x2);
    
    function setUp() public {
        // Deploy facets
        adminFacet = new AdminFacet();
        escrowFacet = new EscrowFacet();
        loanFacet = new LoanFacet();
        priceFacet = new PriceFacet();
        mockNFT = new MockNFT();
        
        // Deploy diamond with facets
        diamond = new DiamondProxy(
            address(adminFacet),
            address(escrowFacet),
            address(loanFacet),
            address(priceFacet)
        );
        
        // Setup test NFT
        mockNFT.mint(borrower, 1);
    }
    
    function testFullLoanCycle() public {
        // Setup
        vm.startPrank(borrower);
        mockNFT.approve(address(diamond), 1);
        
        // Create escrow
        uint256 escrowId = escrowFacet.createEscrow(address(mockNFT), 1);
        assertEq(mockNFT.ownerOf(1), address(diamond));
        
        // Create loan
        vm.stopPrank();
        vm.startPrank(lender);
        uint256 loanAmount = 1 ether;
        uint256 loanId = loanFacet.createLoan{value: loanAmount}(
            escrowId,
            loanAmount,
            0.1 ether,
            7 days
        );
        
        // Verify loan state
        LibDiamond.LoanData memory loan = loanFacet.getLoan(loanId);
        assertEq(loan.borrower, borrower);
        assertEq(loan.lender, lender);
        assertEq(loan.amount, loanAmount);
        
        // Test repayment
        vm.stopPrank();
        vm.startPrank(borrower);
        vm.warp(block.timestamp + 3 days);
        loanFacet.repayLoan{value: loanAmount + 0.1 ether}(loanId);
        
        // Verify final state
        loan = loanFacet.getLoan(loanId);
        assertTrue(loan.repaid);
        assertEq(mockNFT.ownerOf(1), borrower);
    }
}