// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {IEntryPoint} from "account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {PackedUserOperation} from "account-abstraction/contracts/interfaces/PackedUserOperation.sol";

import {SimpleAccount} from "src/SimpleAccount.sol";

contract SimpleAccountHarness is SimpleAccount {
    constructor(IEntryPoint entryPoint, address owner) SimpleAccount(entryPoint, owner) {}

    function expose_validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        public
        view
        returns (uint256)
    {
        return _validateSignature(userOp, userOpHash);
    }
}
