// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface INFTFactory {
    // This is the only function available from the library,
    function _generateTokenURI(
        uint256 _nftID,             // EXPerienceNFT TokenID
        uint256 _tokenAmount,       // EXP Token balance of the owner of this NFT
        address _owner              // Owner of this EXPerienceNFT
    ) external pure returns (
        string memory tokenURI      
    );
}