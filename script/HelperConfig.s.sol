//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract HelperConfig {
    config private s_config;
    address private constant SEPOLIA_FEED =
        0x694AA1769357215DE4FAC081bf1f309aDC325306;

    struct config {
        AggregatorV3Interface _feed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            s_config = getSepoliaConfig();
        } else {
            // do something
        }
    }

    function getSepoliaConfig() private pure returns (config memory _fig) {
        _fig = config(AggregatorV3Interface(SEPOLIA_FEED));
    }

    function getOtherConfig() private pure returns (config memory _fig) {}

    function getConfig() external view returns (config memory _fig) {
        _fig = s_config;
    }
}
