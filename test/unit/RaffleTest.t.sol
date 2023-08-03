// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
// import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Raffle} from "../../src/Raffle.sol";

contract RaffleTest is Test {
    Raffle raffle;

    uint256 private constant ENTRANCE_FEE = 0.1 ether;

    function setUp() external {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint64 subscriptionId,
            bytes32 gasLane,
            uint256 automationUpdateInterval,
            uint256 raffleEntranceFee,
            uint32 callbackGasLimit,
            address vrfCoordinatorV2
        ) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        raffle = new Raffle(
            subscriptionId,
            gasLane,
            automationUpdateInterval,
            raffleEntranceFee,
            callbackGasLimit,
            vrfCoordinatorV2
        );
        vm.stopBroadcast();
    }

    function testEtherAmount() public {
        console.log(raffle.getEntranceFee());
        assertEq(raffle.getEntranceFee(), ENTRANCE_FEE);
    }
}
