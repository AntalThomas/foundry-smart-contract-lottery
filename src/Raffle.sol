// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";


/**
    @title Raffle
    @author Blake Varbai-Heward
    @notice This contract is a simple implementation of a raffle system.
    @dev Implements Chainlink VRFv2.5
*/

contract Raffle is VRFConsumerBaseV2Plus{
    // Errors
    error Raffle__sendMoreToEnterRaffle();

    // State variables
    uint256 private immutable i_entraceFee;
    uint256 private immutable i_interval; // seconds between draws
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    // Events
    event RaffleEntered(address indexed player);

    constructor(uint256 entranceFee, uint256 interval) {
        i_entraceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entraceFee) {
            revert Raffle__sendMoreToEnterRaffle();
        }

        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    function pickWinner() public {
        if (block.timestamp - s_lastTimeStamp < i_interval) {
            revert();
        }

        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );
    }

    // Getters
    function getEntranceFee() external view returns (uint256) { return i_entraceFee; }
}
