// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";

import {IEntryPoint} from "account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {PackedUserOperation} from "account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "account-abstraction/contracts/core/Helpers.sol";

import {SimpleAccount} from "src/SimpleAccount.sol";
import {SimpleAccountHarness} from "test/harness/SimpleAccountHarness.sol";
import {RevertOnEthReceived} from "test/utils/RevertOnEthReceived.sol";

contract SimpleAccountTest is Test {
    SimpleAccountHarness private simpleAccount;
    Account private owner;
    IEntryPoint private entryPoint;

    function setUp() public {
        owner = makeAccount("owner");
        entryPoint = IEntryPoint(makeAddr("entryPoint"));

        simpleAccount = new SimpleAccountHarness(entryPoint, owner.addr);
    }

    function testConstructorSetsEntryPointAndOwner() public view {
        assertEq(address(simpleAccount.entryPoint()), address(entryPoint), "EntryPoint mismatch");
        assertEq(simpleAccount.owner(), owner.addr, "Owner mismatch");
    }

    function testValidateSignatureWithValidOwnerSignatureReturnsSuccess() public view {
        PackedUserOperation memory userOp = PackedUserOperation({
            sender: owner.addr,
            nonce: 0,
            initCode: hex"",
            callData: hex"",
            accountGasLimits: hex"",
            preVerificationGas: 0,
            gasFees: hex"",
            paymasterAndData: hex"",
            signature: hex""
        });

        bytes32 userOpHash = keccak256(abi.encode(userOp));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(owner.key, userOpHash);
        userOp.signature = abi.encodePacked(r, s, v);

        uint256 validationData = simpleAccount.expose_validateSignature(userOp, userOpHash);

        assertEq(validationData, SIG_VALIDATION_SUCCESS, "Signature validation failed for valid owner");
    }

    function testValidateSignatureWithDifferentSignerReturnsFailure() public {
        // Create a random user who is NOT the owner
        Account memory randomUser = makeAccount("randomUser");

        // Prepare a user operation signed by a different user
        PackedUserOperation memory userOp = PackedUserOperation({
            sender: owner.addr,
            nonce: 0,
            initCode: hex"",
            callData: hex"",
            accountGasLimits: hex"",
            preVerificationGas: 0,
            gasFees: hex"",
            paymasterAndData: hex"",
            signature: hex""
        });

        bytes32 userOpHash = keccak256(abi.encode(userOp));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(randomUser.key, userOpHash);
        userOp.signature = abi.encodePacked(r, s, v);

        uint256 validationData = simpleAccount.expose_validateSignature(userOp, userOpHash);

        assertEq(validationData, SIG_VALIDATION_FAILED, "Signature validation should fail for non-owner");
    }

    function testExecuteCallsTargetContractSuccessfully() public {
        address recipient = makeAddr("recipient");

        assertEq(recipient.balance, 0 ether, "Initial recipient balance should be 0 ETH");

        vm.deal(address(simpleAccount), 10 ether);

        vm.prank(address(entryPoint));
        simpleAccount.execute(recipient, 1 ether, hex"");

        assertEq(recipient.balance, 1 ether, "Recipient should have received 1 ETH");
        assertEq(address(simpleAccount).balance, 9 ether, "SimpleAccount should have 9 ETH left");
    }

    function testExecuteRevertsWhenTargetCallFails() public {
        RevertOnEthReceived failingContract = new RevertOnEthReceived();

        vm.deal(address(simpleAccount), 10 ether);

        vm.expectRevert(
            abi.encodeWithSelector(
                SimpleAccount.SimpleAccount__callFailed.selector,
                abi.encodeWithSignature("Error(string)", "DO NOT SEND ETH TO THIS CONTRACT")
            )
        );

        vm.prank(address(entryPoint));
        simpleAccount.execute(address(failingContract), 1 ether, hex"");
    }

    function testExecuteRevertsIfCalledByNonEntryPoint() public {
        address unauthorizedCaller = makeAddr("unauthorizedCaller");

        vm.expectRevert("account: not from EntryPoint");

        vm.prank(unauthorizedCaller);
        simpleAccount.execute(makeAddr("recipient"), 1 ether, hex"");
    }
}
