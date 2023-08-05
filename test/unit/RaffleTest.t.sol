// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";

contract RaffleTest is Test {
    /** Events */
    event EnteredRaffle(address indexed player);

    Raffle raffle;
    HelperConfig helperConfig;

    uint64 subscriptionId;
    bytes32 gasLane;
    uint256 automationUpdateInterval;
    uint256 raffleEntranceFee;
    uint32 callbackGasLimit;
    address vrfCoordinatorV2;
    address link;

    uint256 private constant ENTRANCE_FEE = 0.1 ether;

    address public PLAYER = makeAddr("player");
    uint256 constant STARTING_VALUE = 100 ether; // 1e17

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();
        (
            subscriptionId,
            gasLane,
            automationUpdateInterval,
            raffleEntranceFee,
            callbackGasLimit,
            vrfCoordinatorV2,
            link
        ) = helperConfig.activeNetworkConfig();
        vm.deal(PLAYER, STARTING_VALUE);
    }

    //////////////////
    // EnterRaffle //
    /////////////////

    function testRaffleEnterRevertsIfYouPayNotEnough() public {
        vm.prank(PLAYER);
        // act / assert
        vm.expectRevert(Raffle.Raffle__LowEntraceFee.selector);
        raffle.enterRaffle();
    }

    function testRaffleInitializesInOpenState() public view {
        // Raffle.RaffleState.OPEN -> pick the RaffleState.OPEN from Raffle contract since it is a enum type
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: ENTRANCE_FEE}();
        address playerAddress = raffle.getPlayer(0);
        assertEq(playerAddress, PLAYER);
    }

    function testRaffleEmitsEventsOnRaffleEnter() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: ENTRANCE_FEE}();
    }

    function testRaffleRevertsOnCalculating() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: ENTRANCE_FEE}();
        // passes the time interval
        vm.warp(block.timestamp + automationUpdateInterval + 1);
        // block confirmations
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle__RaffleStateNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: ENTRANCE_FEE}();
    }
}
