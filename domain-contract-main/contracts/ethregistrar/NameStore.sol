// SPDX-License-Identifier: MIT

pragma solidity >=0.8.6;

import "./UniversalRegistrar.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NameStore is Ownable {
    UniversalRegistrar public registrar;

    bool public domainPassEnabled;
    uint256 public domainPassLetterLimit;
    mapping(uint256 => mapping(address => bool)) public domainPassUsed;
    uint256 public domainPassVersion;
    bytes32 public domainPassMerkleRoot;

    mapping(bytes32 => bool) public whitelistEnabled;
    mapping(bytes32 => uint256) public whitelistLimit;
    mapping(bytes32 => mapping(address => uint256)) public whitelistRegistered;
    mapping(bytes32 => bytes32) public whitelistMerkleRoot;

    mapping(uint256 => mapping(bytes32 => mapping(bytes32 => address))) public reservedNames;
    mapping(bytes32 => uint256) public reservedNamesVersion;

    mapping(bytes32 => bool) public registrationsPaused;

    event NameReserved(bytes32 indexed node, string name, address recipient);
    event ReservedNamesCleared(bytes32 indexed node);
    event RegistrationsPauseChanged(bytes32 indexed node, bool paused);

    constructor(UniversalRegistrar _registrar) {
        registrar = _registrar;
    }

    modifier onlyControllerOrOwner(bytes32 node) {
        require(
            registrar.controllers(node, msg.sender) || owner() == msg.sender,
            "Caller is not Controller or Owner!"
        );
        _;
    }

    // =======================================================
    // View Functions

    function isDomainPassEligible(address account) public view returns (bool) {
        return domainPassUsed[domainPassVersion][account];
    }
    
    function isEligibleForWhitelist(bytes32 node, address account) external view returns (bool) {
        return whitelistRegistered[node][account] < whitelistLimit[node];
    }

    function reserved(bytes32 node, bytes32 label) external view returns (address) {
        return reservedNames[reservedNamesVersion[node]][node][label];
    }

    function available(bytes32 node, bytes32 label) external view returns (bool) {
        return reservedNames[reservedNamesVersion[node]][node][label] == address(0) && !registrationsPaused[node];
    }

    // =======================================================
    // Domain Pass Functions

    function setDomainPassEnabled(bool state) external onlyOwner {
        domainPassEnabled = state;
    }

    function setDomainPassLetterLimit(uint256 limit) external onlyOwner {
        domainPassLetterLimit = limit;
    }

    function setDomainPassMerkleRoot(bytes32 merkleRoot) external onlyOwner {
        domainPassMerkleRoot = merkleRoot;
    }

    function useDomainPass(bytes32 node, address account) public onlyControllerOrOwner(node) {
        domainPassUsed[domainPassVersion][account] = true;
    }

    function clearDomainPass() external onlyOwner {
        domainPassVersion++;
    }

    // =======================================================
    // Whitelist Functions

    function setWhitelistEnabled(bytes32 node, bool state) external onlyOwner {
        whitelistEnabled[node] = state;
    }

    function setWhitelistMerkleRoot(bytes32 node, bytes32 merkleRoot) external onlyOwner {
        whitelistMerkleRoot[node] = merkleRoot;
    }

    function setWhitelistLimit(bytes32 node, uint256 limit) external onlyOwner {
       whitelistLimit[node] = limit;
    }

    function increaseWhitelistRegistered(bytes32 node, address account) public onlyControllerOrOwner(node) {
       whitelistRegistered[node][account]++;
    }

    // =======================================================
    // Registration Functions

    function pauseRegistrations(bytes32 node) external onlyOwner {
        registrationsPaused[node] = true;
        emit RegistrationsPauseChanged(node, true);
    }

    function unpauseRegistrations(bytes32 node) external onlyOwner {
        registrationsPaused[node] = false;
        emit RegistrationsPauseChanged(node, false);
    }

    // =======================================================
    // Reserve Functions

    function reserve(bytes32 node, string calldata name, address recipient) external onlyControllerOrOwner(node) {
        bytes32 label = keccak256(bytes(name));
        reservedNames[reservedNamesVersion[node]][node][label] = recipient;
        emit NameReserved(node, name, recipient);
    }

    function bulkReserve(bytes32 node, string[] calldata names, address[] calldata recipients) external onlyOwner {
        require(names.length == recipients.length, "Names and recipients must have the same length");
        for (uint i = 0; i < names.length; i++) {
            bytes32 label = keccak256(bytes(names[i]));
            reservedNames[reservedNamesVersion[node]][node][label] = recipients[i];
            emit NameReserved(node, names[i], recipients[i]);
        }
    }

    function clearReservedNames(bytes32 node) external onlyOwner {
        reservedNamesVersion[node]++;
        emit ReservedNamesCleared(node);
    }
}