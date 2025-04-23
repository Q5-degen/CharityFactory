//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {CharityFactory} from "../src/contracts/CharityFactory.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract DeployCharityFactory is Script {
    function run() external returns (CharityFactory _charityFactory) {
        HelperConfig _helperConfig = new HelperConfig();
        AggregatorV3Interface _feed = _helperConfig.getConfig()._feed;

        vm.startBroadcast();
        _charityFactory = new CharityFactory(_feed);
        vm.stopBroadcast();
    }
}
