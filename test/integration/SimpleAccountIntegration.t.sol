// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";

import {EntryPoint} from "account-abstraction/contracts/core/EntryPoint.sol";
import {IEntryPoint} from "account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {PackedUserOperation} from "account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "account-abstraction/contracts/core/Helpers.sol";

import {SimpleAccount} from "src/SimpleAccount.sol";

contract SimpleAccountIntegration is Test {
    SimpleAccount private simpleAccount;
    EntryPoint private entryPoint;
    Account private owner;
    address private bundler;

    function setUp() public {
        owner = makeAccount("owner");
        bundler = makeAddr("bundler");

        entryPoint = new EntryPoint();
        simpleAccount = new SimpleAccount(entryPoint, owner.addr);

        vm.deal(address(simpleAccount), 10 ether);
        vm.deal(bundler, 10 ether);
    }

    function createUserOp(address recipient, uint256 amount, Account memory signer)
        internal
        view
        returns (PackedUserOperation memory userOp, bytes32 userOpHash)
    {
        bytes memory callData = abi.encodeWithSelector(SimpleAccount.execute.selector, recipient, amount, hex"");

        userOp = PackedUserOperation({
            sender: address(simpleAccount),
            nonce: 0,
            initCode: hex"",
            callData: callData,
            accountGasLimits: bytes32(uint256(100_000) << 128 | uint256(100_000)),
            preVerificationGas: 0,
            gasFees: bytes32(uint256(0) << 128 | uint256(0)),
            paymasterAndData: hex"",
            signature: hex""
        });

        userOpHash = entryPoint.getUserOpHash(userOp);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signer.key, userOpHash);
        userOp.signature = abi.encodePacked(r, s, v);
    }

    function testSimpleAccountWorksOnValidSignature() public {
        (PackedUserOperation memory userOp, bytes32 userOpHash) = createUserOp(makeAddr("recipient"), 1 ether, owner);

        PackedUserOperation[] memory userOps = new PackedUserOperation[](1);
        userOps[0] = userOp;

        vm.prank(bundler);
        vm.expectEmit(true, true, true, false, address(entryPoint));
        emit IEntryPoint.UserOperationEvent(userOpHash, address(simpleAccount), address(0), 0, false, 0, 0);
        entryPoint.handleOps(userOps, payable(bundler));

        assertEq(simpleAccount.getNonce(), 1);
    }

    function testSimpleAccountRevertsOnInvalidSignature() public {
        (PackedUserOperation memory userOp,) = createUserOp(makeAddr("recipient"), 1 ether, makeAccount("randomUser"));

        PackedUserOperation[] memory userOps = new PackedUserOperation[](1);
        userOps[0] = userOp;

        vm.prank(bundler);
        vm.expectRevert(abi.encodeWithSelector(IEntryPoint.FailedOp.selector, 0, "AA24 signature error"));
        entryPoint.handleOps(userOps, payable(bundler));
    }
}
