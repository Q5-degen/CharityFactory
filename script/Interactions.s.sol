// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {CharityFactory} from "../src/contracts/CharityFactory.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract RegisterCharity is Script {
    string private constant NAME = "Sponge_Bob";
    uint256 private constant MIN_DONATION = 10e18;

    function register(
        string memory _charityName,
        uint256 _minDonation,
        address _CFAddr
    ) public {
        vm.startBroadcast();
        CharityFactory(payable(_CFAddr)).register(_charityName, _minDonation);
        vm.stopBroadcast();
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "CharityFactory",
            block.chainid
        );

        register(NAME, MIN_DONATION, contractAddress);
    }
}

contract Donate is Script {
    string private constant NAME = "Sponge_Bob";
    uint256 private constant AMOUNT_TO_BE_DONATED = 9e15;

    function donate(
        string memory _charityName,
        uint256 _amountToBeDonated,
        address _CFAddr
    ) public payable {
        vm.startBroadcast();
        CharityFactory(payable(_CFAddr)).donate{value: _amountToBeDonated}(
            _charityName,
            _amountToBeDonated
        );
        vm.stopBroadcast();
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "CharityFactory",
            block.chainid
        );

        donate(NAME, AMOUNT_TO_BE_DONATED, contractAddress);
    }
}

contract WithdrawDonation is Script {
    function withdraw(address _CFAddr) public {
        vm.startBroadcast();
        CharityFactory(payable(_CFAddr)).withdrawDonation();
        vm.stopBroadcast();
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "CharityFactory",
            block.chainid
        );

        withdraw(contractAddress);
    }
}
