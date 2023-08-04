// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2Mock} from "../test/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfig is Script {
    uint96 public constant BASE_FEE = 100000000000000000;
    uint96 public constant GAS_PRICE_LINK = 1000000000;

    NetworkConfig public activeNetworkConfig;
    struct NetworkConfig {
        uint64 subscriptionId;
        bytes32 gasLane;
        uint256 automationUpdateInterval;
        uint256 raffleEntranceFee;
        uint32 callbackGasLimit;
        address vrfCoordinatorV2;
        // address link;
        // uint256 deployerKey;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnerEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            subscriptionId: 0,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            automationUpdateInterval: 500000,
            raffleEntranceFee: 0.1 ether,
            callbackGasLimit: 2500000,
            vrfCoordinatorV2: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
        });
        return sepoliaConfig;
    }

    function getMainnerEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            subscriptionId: 0,
            gasLane: 0xff8dedfbfa60af186cf3c830acbc32c05aae823045ae5ea7da1e45fbfaba4f92,
            automationUpdateInterval: 500000,
            raffleEntranceFee: 0.1 ether,
            vrfCoordinatorV2: 0x271682DEB8C4E0901D1a1550aD2e64D568E69909,
            callbackGasLimit: 2500000
        });
        return mainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinatorV2 != address(0))
            return activeNetworkConfig;

        // 1. deploy the mocks
        // 2. get the address
        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorV2Mock = new VRFCoordinatorV2Mock(
            BASE_FEE,
            GAS_PRICE_LINK
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            subscriptionId: 234,
            gasLane: 0xff8dedfbfa60af186cf3c830acbc32c05aae823045ae5ea7da1e45fbfaba4f92,
            automationUpdateInterval: 500000,
            raffleEntranceFee: 0.1 ether,
            // vrfCoordinatorV2: 0x271682DEB8C4E0901D1a1550aD2e64D568E69909,
            vrfCoordinatorV2: address(vrfCoordinatorV2Mock),
            callbackGasLimit: 2500000
        });
        return anvilConfig;
    }
}
