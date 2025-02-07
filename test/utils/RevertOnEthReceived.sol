// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

contract RevertOnEthReceived {
    receive() external payable {
        revert("DO NOT SEND ETH TO THIS CONTRACT");
    }
}