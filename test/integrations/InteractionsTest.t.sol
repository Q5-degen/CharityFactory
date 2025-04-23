// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployCharityFactory} from "../../script/DeployCharityFactory.s.sol";
import {CharityFactory, AddDonations} from "../../src/contracts/CharityFactory.sol";
import {RegisterCharity, Donate, WithdrawDonation} from "../../script/Interactions.s.sol";

contract CharityFactoryTest is Test {
    CharityFactory private s_charityF;
    RegisterCharity private s_register;
    Donate private s_donate;
    WithdrawDonation private s_withdraw;

    address private s_charityFAddr;
    address randomAddressCreated = makeAddr("Big Balls");
    address randomDonner = makeAddr("donner");

    function setUp() external {
        DeployCharityFactory _deployCF = new DeployCharityFactory();
        s_charityF = _deployCF.run();
        s_charityFAddr = address(s_charityF);
        s_register = new RegisterCharity();
        s_donate = new Donate();
        s_withdraw = new WithdrawDonation();
        vm.deal(randomDonner, 10e18);
    }

    function testRegisterDonateWithdrawSucceed() external {
        string memory name = "Sponge_Bob";
        uint256 minDonation = 10e18;
        uint256 amountDonated = 9e15;

        s_register.register(name, minDonation, s_charityFAddr);
        address createDonationContract = s_charityF.getDonationContractAddress(
            0
        );

        s_donate.donate{value: amountDonated}(
            name,
            amountDonated,
            s_charityFAddr
        );
        uint256 allowWithdrawerBalBeforeWithdraw = address(msg.sender).balance;
        uint256 donationContractBalBeforewithdraw = address(
            createDonationContract
        ).balance;

        s_withdraw.withdraw(s_charityFAddr);
        uint256 allowWithdrawerFinalBalanace = address(msg.sender).balance;

        assertEq(
            allowWithdrawerFinalBalanace,
            allowWithdrawerBalBeforeWithdraw + donationContractBalBeforewithdraw
        );
    }

    receive() external payable {}
}
