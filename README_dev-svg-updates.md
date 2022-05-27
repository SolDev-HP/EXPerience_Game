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