//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error AddDonations__DonationNotEnough();
error AddDonations__DonationsWithdrawFailed();
error AddDonations__CallerNotAllow();
error AddDonations__WrongCaller();
error AddDonations__BalanceNull();
error AddDonations__LengthNull();

contract AddDonations {
    uint256 private immutable i_minUsdDonation;
    AggregatorV3Interface private immutable i_priceFeed;
    address[] private s_donners;
    mapping(address _donner => uint256 _donnation) private s_donnerToAmount;
    address private immutable i_allowedWithdrawer;
    address private immutable i_charityFactory;

    constructor(
        uint256 _setMinDonationInUsd,
        AggregatorV3Interface _feed,
        address _allowedWithdrawer,
        address _charityFactory
    ) {
        i_minUsdDonation = _setMinDonationInUsd;
        i_priceFeed = _feed;
        i_allowedWithdrawer = _allowedWithdrawer;
        i_charityFactory = _charityFactory;
    }

    function addDonation(address _donner) public payable {
        if (msg.sender != i_charityFactory) revert AddDonations__WrongCaller();

        if (convertEthToUsd(msg.value) < i_minUsdDonation)
            revert AddDonations__DonationNotEnough();

        s_donners.push(_donner);
        s_donnerToAmount[_donner] = s_donnerToAmount[_donner] + msg.value;
    }

    function withdrawDonations(address _caller) external {
        if (msg.sender != i_charityFactory) revert AddDonations__WrongCaller();
        if (_caller != i_allowedWithdrawer)
            revert AddDonations__CallerNotAllow();
        if (address(this).balance == 0) revert AddDonations__BalanceNull();

        for (uint256 index = 0; index < s_donners.length; index++) {
            s_donnerToAmount[s_donners[index]] = 0;
        }

        s_donners = new address[](0);

        (bool sent, ) = payable(_caller).call{value: address(this).balance}("");
        if (!sent) revert AddDonations__DonationsWithdrawFailed();
    }

    function getEthPrice() private view returns (uint256 _price) {
        (, int256 answer, , , ) = i_priceFeed.latestRoundData();
        _price = uint256(answer * 1e10);
    }

    function convertEthToUsd(
        uint256 _ethAmount
    ) private view returns (uint256 _usd) {
        uint256 price = getEthPrice();
        _usd = (_ethAmount * price) / 1e18;
    }

    function checkDonnerAddr(
        uint256 _donnerIndex
    ) external view returns (address _donner) {
        _donner = s_donners[_donnerIndex];
    }

    function checkDonnerAmount(
        address _donnerAddress
    ) external view returns (uint256 _donnation) {
        _donnation = s_donnerToAmount[_donnerAddress];
    }

    function checkNumOfDonner() external view returns (uint256 _length) {
        _length = s_donners.length;
    }

    receive() external payable {
        addDonation(msg.sender);
    }

    fallback() external payable {
        addDonation(msg.sender);
    }
}
