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
        adminFacet = new AdminFacet();
        escrowFacet = new EscrowFacet();
        loanFacet = new LoanFacet();
        priceFacet = new PriceFacet();
        mockNFT = new MockNFT();

        diamond = new DiamondProxy(address(adminFacet));
        diamond.updateFacet(bytes4(keccak256("escrowFacet()")), address(escrowFacet));
        diamond.updateFacet(bytes4(keccak256("loanFacet()")), address(loanFacet));
        diamond.updateFacet(bytes4(keccak256("priceFacet()")), address(priceFacet));

        mockNFT.mint(borrower, 1);
    }

function testFullLoanCycle() public {
    vm.startPrank(borrower);
    mockNFT.approve(address(diamond), 1);  

    uint256 escrowId = escrowFacet.createEscrow(address(mockNFT), 1);
    assertEq(mockNFT.ownerOf(1), address(diamond));  

    vm.stopPrank();
    vm.startPrank(lender);
    uint256 loanAmount = 1 ether;
    uint256 loanId = loanFacet.createLoan{value: loanAmount}(
        escrowId,
        0.1 ether, // Interest
        7 days     // Duration
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
