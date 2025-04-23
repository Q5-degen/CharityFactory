// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployCharityFactory} from "../../script/DeployCharityFactory.s.sol";
import {CharityFactory, AddDonations} from "../../src/contracts/CharityFactory.sol";

contract CharityFactoryTest is Test {
    CharityFactory private s_charityF;
    address private s_charityFAddr;
    address randomAddressCreated = makeAddr("Big Balls");
    address randomDonner = makeAddr("donner");

    function setUp() external {
        DeployCharityFactory _deployCF = new DeployCharityFactory();
        s_charityF = _deployCF.run();
        s_charityFAddr = address(s_charityF);
        vm.deal(randomDonner, 10e18);
    }

    function testCheckCharityFOwnerAddr() external view {
        address owner = s_charityF.checkCharityFactoryOwner();

        assertEq(owner, msg.sender);
    }

    function testcheckNoDonnationContractCreatedYet() external view {
        uint256 num = s_charityF.checkDonationContractListLength();
        assertEq(num, 0);
    }

    function testCheckDonnerAddressesByDonationContractFailedWithNoDonationsContractCreatedYet()
        external
    {
        vm.expectRevert();
        s_charityF.checkDonnerAddressesByDonationContract(
            randomAddressCreated,
            0
        );
    }

    function testcheckDonnerAddressesByDonationContractFailedWithDonationContractDoesntExist()
        external
    {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";
        s_charityF.register(charityName, minDonationRequired);

        assertEq(s_charityF.checkDonationContractListLength(), 1);

        vm.expectRevert();
        s_charityF.checkDonnerAddressesByDonationContract(
            randomAddressCreated,
            0
        );
    }

    function testcheckDonnerAddressesByDonationContractFailedWithNoDonnerYet()
        external
    {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";
        s_charityF.register(charityName, minDonationRequired);
        address donationContractCreated = s_charityF.getDonationContractAddress(
            0
        );

        assertEq(s_charityF.checkDonationContractListLength(), 1);

        vm.expectRevert();
        s_charityF.checkDonnerAddressesByDonationContract(
            donationContractCreated,
            0
        );
    }

    function testCheckDonnerAddressesByDonationContractExist() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        s_charityF.register(charityName, minDonationRequired);
        address donationContractCreated = s_charityF.getDonationContractAddress(
            0
        );
        assertEq(s_charityF.checkDonationContractListLength(), 1);

        vm.prank(randomDonner);
        s_charityF.donate{value: 9e15}(charityName, 9e15);

        address retrievedDonner = s_charityF
            .checkDonnerAddressesByDonationContract(donationContractCreated, 0);

        assertEq(retrievedDonner, randomDonner);
    }

    function testGetDonationContractAddressFailedWithDonationContractListEmpty()
        external
    {
        vm.expectRevert();
        s_charityF.getDonationContractAddress(0);
    }

    function testGetDonationContractAddressFailedWithContractAddressDoesntExist()
        external
    {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        s_charityF.register(charityName, minDonationRequired);

        vm.expectRevert();
        s_charityF.getDonationContractAddress(1);
    }

    function testCheckDonationContractBalFailedWithNoDonnationContractCreatedYet()
        external
    {
        vm.expectRevert();
        s_charityF.checkDonationContractBal(randomAddressCreated);
    }

    function testCheckDonationContractBalDonationContractDoesntExist()
        external
    {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        s_charityF.register(charityName, minDonationRequired);

        vm.expectRevert();
        s_charityF.checkDonationContractBal(randomAddressCreated);
    }

    function testCheckDonationContractBalSucceed() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        s_charityF.register(charityName, minDonationRequired);
        address donationContractCreated = s_charityF.getDonationContractAddress(
            0
        );
        assertEq(s_charityF.checkDonationContractListLength(), 1);

        uint256 bal = s_charityF.checkDonationContractBal(
            donationContractCreated
        );
        assertEq(bal, 0);
    }

    function testCheckDonnerNumByDonationContractFailedWithNoDonnationContractCreatedYet()
        external
    {
        vm.expectRevert();
        s_charityF.checkDonnerNumByDonationContract(randomAddressCreated);
    }

    function testCheckDonnerNumByDonationContractFailedWithDonationContractDoesntExist()
        external
    {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        s_charityF.register(charityName, minDonationRequired);

        vm.expectRevert();
        s_charityF.checkDonnerNumByDonationContract(randomAddressCreated);
    }

    function testCheckDonnerNumByDonationContractSucceed() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        s_charityF.register(charityName, minDonationRequired);
        address donationContractCreated = s_charityF.getDonationContractAddress(
            0
        );
        assertEq(s_charityF.checkDonationContractListLength(), 1);

        vm.prank(randomDonner);
        s_charityF.donate{value: 9e15}(charityName, 9e15);

        uint256 donnerNub = s_charityF.checkDonnerNumByDonationContract(
            donationContractCreated
        );
        assertEq(donnerNub, 1);
    }

    function testWithdrawDonationFailedWithMsgSenderNotRegistered() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        s_charityF.register(charityName, minDonationRequired);

        vm.prank(randomDonner);
        vm.expectRevert();
        s_charityF.withdrawDonation();
    }

    function testWithdrawDonationFailedWithBalanceNull() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        s_charityF.register(charityName, minDonationRequired);

        vm.expectRevert();
        s_charityF.withdrawDonation();
    }

    function testWithdrawDonationSucceed() external {
        uint256 registeredCharityAccountBalAtStart = address(msg.sender)
            .balance;
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        vm.prank(msg.sender);
        s_charityF.register(charityName, minDonationRequired);

        address donationContractCreated = s_charityF.getDonationContractAddress(
            0
        );
        assertEq(s_charityF.checkDonationContractListLength(), 1);

        vm.prank(randomDonner);
        s_charityF.donate{value: 9e15}(charityName, 9e15);
        uint256 createdContractDonnationBalAfterDonation = address(
            donationContractCreated
        ).balance;

        vm.prank(msg.sender);
        s_charityF.withdrawDonation();

        uint256 registeredCharityAccountBalAtFter = address(msg.sender).balance;
        assertEq(
            registeredCharityAccountBalAtFter,
            registeredCharityAccountBalAtStart +
                createdContractDonnationBalAfterDonation
        );
    }

    function testAddDonationFailedWithWrongCaller() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        s_charityF.register(charityName, minDonationRequired);

        address donationContractCreated = s_charityF.getDonationContractAddress(
            0
        );

        vm.expectRevert();
        AddDonations(payable(donationContractCreated)).addDonation{value: 9e15}(
            msg.sender
        );
    }

    function testAddDonationFailedWithDonationNotEnough() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        vm.prank(msg.sender);
        s_charityF.register(charityName, minDonationRequired);

        vm.expectRevert();
        s_charityF.donate{value: 1e15}(charityName, 1e15);
    }

    function testWithdrawDonationsFailedWithWrongCaller() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        vm.prank(msg.sender);
        s_charityF.register(charityName, minDonationRequired);

        address donationContractCreated = s_charityF.getDonationContractAddress(
            0
        );

        vm.expectRevert();
        AddDonations(payable(donationContractCreated)).withdrawDonations(
            msg.sender
        );
    }

    function testWithdrawDonationsFailedWithCallerNotAllow() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        vm.prank(msg.sender);
        s_charityF.register(charityName, minDonationRequired);

        address donationContractCreated = s_charityF.getDonationContractAddress(
            0
        );

        vm.prank(s_charityFAddr);
        vm.expectRevert();
        AddDonations(payable(donationContractCreated)).withdrawDonations(
            s_charityFAddr
        );
    }

    function testWithdrawDonationsFailedWithBalanceNull() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        vm.prank(msg.sender);
        s_charityF.register(charityName, minDonationRequired);

        address donationContractCreated = s_charityF.getDonationContractAddress(
            0
        );

        vm.prank(s_charityFAddr);
        vm.expectRevert();
        AddDonations(payable(donationContractCreated)).withdrawDonations(
            msg.sender
        );
    }

    function testWithdrawDonationsFailedWithDonationsWithdrawFailed() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        s_charityF.register(charityName, minDonationRequired);

        vm.prank(randomDonner);
        s_charityF.donate{value: 9e15}(charityName, 9e15);

        vm.expectRevert();
        s_charityF.withdrawDonation();
    }

    function testcheckNumOfDonner() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        s_charityF.register(charityName, minDonationRequired);
        address donationContractCreated = s_charityF.getDonationContractAddress(
            0
        );

        uint256 num = AddDonations(payable(donationContractCreated))
            .checkNumOfDonner();
        assertEq(num, 0);
    }

    function testCheckDonnerAmount() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        s_charityF.register(charityName, minDonationRequired);
        address donationContractCreated = s_charityF.getDonationContractAddress(
            0
        );

        vm.prank(randomDonner);
        s_charityF.donate{value: 9e15}(charityName, 9e15);

        uint256 donation = AddDonations(payable(donationContractCreated))
            .checkDonnerAmount(randomDonner);
        assertEq(donation, 9e15);
    }

    function testCheckDonnerAddr() external {
        uint256 minDonationRequired = 10e18;
        string memory charityName = "deez nutz";

        s_charityF.register(charityName, minDonationRequired);
        address donationContractCreated = s_charityF.getDonationContractAddress(
            0
        );

        vm.prank(randomDonner);
        s_charityF.donate{value: 9e15}(charityName, 9e15);

        address donnerAddr = AddDonations(payable(donationContractCreated))
            .checkDonnerAddr(0);
        assertEq(donnerAddr, randomDonner);
    }
}
