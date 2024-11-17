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
            pickaxeNftCollection.safeTransferFrom(
                address(this),
                msg.sender,
                playerPickaxe[msg.sender].value,
                1,
                "Returning your old pickaxe"
            );
        }
 
        uint256 reward = calculateRewards(msg.sender);
        rewardsToken.transfer(msg.sender, reward);

       
        pickaxeNftCollection.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            1,
            "Staking your pickaxe"
        );

        // Update the playerPickaxe mapping
        playerPickaxe[msg.sender].value = _tokenId;
        playerPickaxe[msg.sender].isData = true;
        playerLastUpdate[msg.sender].isData = true;
        playerLastUpdate[msg.sender].value = block.timestamp;
    }

    function withdraw() external nonReentrant {
        // Ensure the player has a pickaxe
        require(
            playerPickaxe[msg.sender].isData,
            "You do not have a pickaxe to withdraw."
        );

        uint256 reward = calculateRewards(msg.sender);
        rewardsToken.transfer(msg.sender, reward);

        
        pickaxeNftCollection.safeTransferFrom(
            address(this),
            msg.sender,
            playerPickaxe[msg.sender].value,
            1,
            "Returning your old pickaxe"
        );

       
        playerPickaxe[msg.sender].isData = false;


        playerLastUpdate[msg.sender].isData = true;
        playerLastUpdate[msg.sender].value = block.timestamp;
    }

    function claim() external nonReentrant {
       
        uint256 reward = calculateRewards(msg.sender);
        rewardsToken.transfer(msg.sender, reward);

        
        playerLastUpdate[msg.sender].isData = true;
        playerLastUpdate[msg.sender].value = block.timestamp;
    }


    // Calculate the rewards the player is owed since last time they were paid out
    
    function calculateRewards(address _player)
        public
        view
        returns (uint256 _rewards)
    {
       
        if (
            !playerLastUpdate[_player].isData || !playerPickaxe[_player].isData
        ) {
            return 0;
        }

        uint256 timeDifference = block.timestamp -
            playerLastUpdate[_player].value;

        uint256 rewards = timeDifference *
            10_000_000_000_000 *
            (playerPickaxe[_player].value + 1);

  
        return rewards;
    }
}