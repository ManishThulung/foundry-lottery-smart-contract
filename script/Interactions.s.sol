// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (, , , , , address vrfCoordinatorV2, ) = helperConfig
            .activeNetworkConfig();
        return createSubscription(vrfCoordinatorV2);
    }

    function createSubscription(
        address vrfCoordinatorV2
    ) public returns (uint64) {
        console.log("Creating Subscription on chainId: ", block.chainid);
        vm.startBroadcast();
        uint64 _subId = VRFCoordinatorV2Mock(vrfCoordinatorV2)
            .createSubscription();
        vm.stopBroadcast();
        console.log("Your subscriptin id is: ", _subId);
        console.log("please update your sub id in helper file");
        return _subId;
    }

    function run() external returns (uint64) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    uint96 private constant FUND_AMT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint64 subId,
            ,
            ,
            ,
            ,
            address vrfCoordinatorV2,
            address link
        ) = helperConfig.activeNetworkConfig();
        fundSubscription(vrfCoordinatorV2, subId, link);
    }

    function fundSubscription(
        address vrfCoordinatorV2,
        uint64 subId,
        address link
    ) public {
        console.log("Subscription ID: ", subId);
        console.log("Using vrfCoordinator: ", vrfCoordinatorV2);
        console.log("On ChainId: ", block.chainid);

        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinatorV2).fundSubscription(
                subId,
                FUND_AMT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(link).transferAndCall(
                vrfCoordinatorV2,
                FUND_AMT,
                abi.encode(subId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address raffle) public {
        HelperConfig helperConfig = new HelperConfig();
        (uint64 subId, , , , , address vrfCoordinatorV2, ) = helperConfig
            .activeNetworkConfig();
        addConsumer(raffle, vrfCoordinatorV2, subId);
    }

    function addConsumer(
        address raffle,
        address vrfCoordinatorV2,
        uint64 subId
    ) public {
        console.log("Subscription ID: ", subId);
        console.log("Using vrfCoordinator: ", vrfCoordinatorV2);
        console.log("On contract address: ", raffle);
        console.log("On ChainId: ", block.chainid);

        vm.startBroadcast();
        VRFCoordinatorV2Mock(vrfCoordinatorV2).addConsumer(subId, raffle);
        vm.stopBroadcast();
    }

    function run() external {
        address raffleAddress = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(raffleAddress);
    }
}
