#### Status - Deployed 

- Currently deployed to rinkeby with updated svg designs received from Aleta 
Rinkeby Testnet: https://rinkeby.etherscan.io/address/0xE23ADC5e1E3C47243d0b14Eb8EC0cA7D53901Fab
Opensea Link: https://testnets.opensea.io/collection/experience-nft-jm2r5z4ecm
Rarible Link: https://rinkeby.rarible.com/collection/0xe23adc5e1e3c47243d0b14eb8ec0ca7d53901fab/items

- Updates:
- Deployed bytecode size finally under control (with using Factory inside main contract)

- Work in progress:
- Still looking out more way to reduce deployed bytecode size. 

##### As we change from basic NFT generation to move advanced mode
- Currently library (BadgeLibrary) becomes huge
- Contract deployment code size goes beyond 24k limit 
```
New compatible solc version available: 0.8.13
Compiling contracts...
  Solc version: 0.8.13
  Optimizer: Enabled  Runs: 200
  EVM Version: Istanbul
Generating build data...
 - EXPerienceNFT
WARNING: deployed size of EXPerienceNFT is 28471.0 bytes, exceeds EIP-170 limit of 24577  
 - ERC165
 - ERC165Storage
 - BadgeFactory
 - ERC721
 - Base64
 - Context
 - Ownable
 - Strings
 - IERC20
 - IERC721
 - IERC721Metadata
 - IERC165
```

- It feels as if this is (28471.0 bytes) as far as we can stretch it if we want to include Library as internal functionality 
- If library is deployed seperately and then handled with, I doubt there'll be much deployment size issue. (Tests ongoing)

##### Updates 

- EthernautFactory seperated from BadgeFactory. Same logic though different svg core generation method 
- This library is now seperately deployed and the address is then passed on into EXPerienceNFT contract 
- This way we can re-add those 4k bytes of _svgCore4 that we removed for testing purposes. 
- Current status
```
If Library and EXPerienceNFT contracts are deployed together
  - contract deployment bytecode is 28k. Still need to find a way to remove those 4k overhead bytes 
If Library deployed seperately 
  - use library address in EXPerience NFT contract, passing into constructor, same as EXP 
```