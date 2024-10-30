// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "../src/facets/LoanFacet.sol";
import "../src/facets/EscrowFacet.sol";
import "../src/facets/LiquidationFacet.sol";
import "../src/DiamondProxy.sol";
import "forge-std/Vm.sol";

contract LendingPlatformTest is DSTest {
    Vm public vm = Vm(HEVM_ADDRESS);
    LoanFacet loanFacet;
    EscrowFacet escrowFacet;
    LiquidationFacet liquidationFacet;
    DiamondProxy proxy;

    function setUp() public {
        // Deploy facets
        loanFacet = new LoanFacet();
        escrowFacet = new EscrowFacet();
        liquidationFacet = new LiquidationFacet();

        // Deploy proxy and initialize facets
        proxy = new DiamondProxy(address(loanFacet));
    }

    function testLoanInitiation() public {
        // Mock initiate loan through proxy
        loanFacet.initiateLoan(1 ether);
        assertEq(loanFacet.loanCounter(), 1);
    }

   function testRepayment() public {
    loanFacet.initiateLoan(1 ether);
    uint256 loanId = loanFacet.loanCounter();

    loanFacet.repayLoan(loanId);

    LoanFacet.Loan memory loan = loanFacet.getLoan(loanId);
    assertTrue(loan.repaid);
}



function testLiquidation() public {
    // Create a loan and use the correct loan ID
    loanFacet.initiateLoan(1 ether);
    uint256 loanId = loanFacet.loanCounter(); // Get the loan ID directly

    // Mark the loan as defaulted
    loanFacet.setLoanAsDefaulted(loanId);

    // Liquidate the defaulted loan
    liquidationFacet.liquidate(loanId);

    // Verify that the loan's default status is true after liquidation
    assertTrue(liquidationFacet.getLoanDefaultStatus(loanId));
}



}
