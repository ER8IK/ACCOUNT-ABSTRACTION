// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";

contract HelperConfig is Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        address entryPoint;
        address account;
    }

    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 constant LOCAL_CHAIN_ID = 31337;
    address constant FOUNDRY_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs; 

    address constant FOUNDRY_DEFAULT_WALLET = 0x0000000000000000000000000000000000000000;


    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getEthSepoliaConfig();
    }

    function getConfig() public returns(NetworkConfig memory){
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(uint256 chainId) public returns(NetworkConfig memory) {
        if(chainId == LOCAL_CHAIN_ID){
            return getOrCreateAnvilEthConfig();
        } else if (networkConfigs[chainId].entryPoint != address(0)){
            return networkConfigs[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getEthSepoliaConfig() public pure returns(NetworkConfig memory){
        return NetworkConfig({
            entryPoint: 0x0000000000000000000000000000000000000000,
            account: 0x0000000000000000000000000000000000000000
        });
    }

    function getZkSyncSepoliaConfig() public pure returns(NetworkConfig memory){
        return NetworkConfig({
            entryPoint: 0x0000000000000000000000000000000000000000,
            account: 0x0000000000000000000000000000000000000000
        });
    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory){
        if (localNetworkConfig.entryPoint != address(0)) {
            return localNetworkConfig;
        }

        // deploy mocks
        console2.log("Deploying mocks...");
        vm.startBroadcast(FOUNDRY_DEFAULT_ACCOUNT);
        EntryPoint entryPoint = new EntryPoint();
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({entryPoint: address(entryPoint), account: FOUNDRY_DEFAULT_ACCOUNT});

        return localNetworkConfig;
    }
}