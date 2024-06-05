# arttoo-dealing

## Project Introduction
Artoo aims to fractionalize the existing artwork and make it accessible to a larger audience with the help of tokenization. Holding a token associated with certain art gives you the fractional ownership of that art.

## Design 
To associate a token with an NFT, a specific deployment sequence is necessary. First, we must register the token. This registration requires a One Time Witness (OTW), which is only accessible in the module's constructor. Since the constructor function can only be invoked during contract deployment, we need to deploy a new module for each new token.

## Possible Solution
Every time we want to mint a new NFT, first we will deploy a new token contract for that NFT and pass the Token reference as a parameter of the mint NFT function along with NFT details. 

## Arttoo Inventory
Arttoo inventory is to aggregate all the minted NFT in the platform. We will store the token id of all the minted NFT in the inventory contract that might be useful for the frontend to display all the minted NFT and their details.

