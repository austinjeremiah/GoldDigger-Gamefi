// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@thirdweb-dev/contracts/drop/DropERC1155.sol"; // For my collection of Pickaxes
import "@thirdweb-dev/contracts/token/TokenERC20.sol"; // For my ERC-20 Token (GOLD)

import "@thirdweb-dev/contracts/openzeppelin-presets/utils/ERC1155/ERC1155Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Mining is ReentrancyGuard, ERC1155Holder {
   
    DropERC1155 public immutable pickaxeNftCollection;
    TokenERC20 public immutable rewardsToken;

    constructor(
        DropERC1155 pickaxeContractAddress,
        TokenERC20 gemsContractAddress
    ) {
        pickaxeNftCollection = pickaxeContractAddress;
        rewardsToken = gemsContractAddress;
    }

    struct MapValue {
        bool isData;
        uint256 value;
    }
     mapping(address => MapValue) public playerPickaxe;

   
    mapping(address => MapValue) public playerLastUpdate;

    function stake(uint256 _tokenId) external nonReentrant {
        
        require(
            pickaxeNftCollection.balanceOf(msg.sender, _tokenId) >= 1,
            "You must have at least 1 of the pickaxe you are trying to stake or buy it from the shop"
        );
 if (playerPickaxe[msg.sender].isData) {
            // Transfer using safeTransfer
            pickaxeNftCollection.safeTransferFrom(
                address(this),
                msg.sender,
                playerPickaxe[msg.sender].value,
                1,
                "Returning your old pickaxe"
            );
        }
