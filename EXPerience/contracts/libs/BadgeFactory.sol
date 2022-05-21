// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../utils/Strings.sol";
import "../utils/Base64.sol";

// BadgeFactory that will be used by EXPerienceNFT 
// to generate badges that support necessary update passed in
// by tokenURI() function call 
library BadgeFactory {
    // Define our SVG - We are capping our viewbox to 300 300 
    // SVG containers 

    // Finally found a solution to intergate css animation and svg inside an svg. Current output is satisfying 
    // with expected quality expectations matching. Still requires continuous updates and improvements
    string internal constant _svgCont_Start = '<svg viewBox="0 0 300 300" xmlns="http://www.w3.org/2000/svg"> <style type="text/css"> <![CDATA[ *, *:before, *:after { box-sizing: border-box;} body { height: 100vh; background: #000;} .center { height: 100%; display: flex; align-items: center; justify-content: center; text-align: center;} .circle { position: relative; width: 200px; height: 200px; color: #fff; background: #000; border-radius: 50%; border: 2px solid;} .logo { font-size: 125px; line-height: 190px; vertical-align: middle;} .button { position: absolute; bottom: 0px; left: 0; right: 0; padding: 8px; font-weight: bold; text-transform: uppercase; background: #000; border: 2px solid; animation: slide 1.4s ease-in-out infinite; cursor: pointer;} .button:hover { color: #000; background: #fff; border-color: #fff;} @keyframes slide { 0% { transform: translateX(10px) } 50% {transform: translateX(-10px) } 100% { transform: translateX(10px) }} .text { position: absolute; top: 0; left: 0; width: 100%; height: 100%; font-size: 24px; font-weight: bold; text-transform: uppercase; animation: rotate 14s linear infinite; fill: #fff;} @keyframes rotate { from { transform: rotate(0); } to { transform: rotate(360deg); }} ]]> </style> <foreignObject x="20" y="20" width="300" height="300"><!-- In the context of SVG embedded in an HTML document, the XHTML  namespace could be omitted, but it is mandatory in the  context of an SVG document --> <div class="center" xmlns="http://www.w3.org/1999/xhtml"><div class="circle" xmlns="http://www.w3.org/1999/xhtml"><div class="logo" xmlns="http://www.w3.org/1999/xhtml">II</div><div class="text" xmlns="http://www.w3.org/1999/xhtml">  <svg x="0" y="0" viewBox="0 0 300 300" enable-background="new 0 0 300 300" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"> <defs> <path id="circlePath" d=" M 150, 150 m -120, 0 a 120,120 0 0,1 240,0 a 120,120 0 0,1 -240,0 "  /> </defs> <g> <text> <textPath href="#circlePath" xml:space="preserve">EXPerience NFT!         For.EthernautDAO         Level - ';

    string internal constant _svgCont_Mid = '</textPath></text></g></svg></div><div class="button" xmlns="http://www.w3.org/1999/xhtml">[EXP] Balance - ';

    string internal constant _svgCont_End = '</div></div></div></foreignObject></svg>';

    // Base64 encoded version of the svg container with styles added
    // Now our SVG container contains enough information about person holding the NFT, their EXP balance 
    // Everything on-chain (The exciting part or the part that motivates me further to develop better solutions) 
    function _base64EncodeImage(uint256 _tokenAmount) internal pure returns (string memory) {
        string memory _returning_svg = Base64.encode(abi.encodePacked(
                _svgCont_Start,
                _getExperienceLevel(_tokenAmount),  
                _svgCont_Mid,
                Strings.toString(_tokenAmount),
                _svgCont_End 
            ));

        return string(abi.encodePacked("data:image/svg+xml;base64,", _returning_svg)); 
    }

    // Styles for the image 
    //function _getStyleForAnimation() internal pure returns (string memory) {
        // If ever required internal styles, use this function
    //}

    // Get experience level based on EXP token amount being held by user 
    // The easiest I could come up with in order to prototype this
    function _getExperienceLevel(uint256 _tokenAmount) internal pure returns (string memory) {
        if(_tokenAmount >= 0 && _tokenAmount <= 20)
            return "I";
        else if(_tokenAmount > 20 && _tokenAmount <= 40)
            return "II";
        else if(_tokenAmount > 40 && _tokenAmount <= 60)
            return "III";
        else if(_tokenAmount > 60 && _tokenAmount <= 80)
            return "IV";
        else 
            return "-G-";
    }

    // Now the main function that will handle generating actual token url 
    /// @param _nftID - NFT token ID for which this function call is happening 
    /// @param _tokenAmount - Value of total EXP Token the owner of the NFT has 
    function _generateTokenURI(uint256 _nftID, uint256 _tokenAmount, address _owner) internal pure returns (string memory tokenURI) {
        // Get our image url prepared with _tokenAmount 
        string memory _imgUrl = _base64EncodeImage(_tokenAmount);
        // Get experience level that can be show in the middle of the image 
        string memory _expLevel = _getExperienceLevel(_tokenAmount);
        
        // Json that will be returned when tokenURI function request is received 
        // This prepared the expected response format, including all the necessary data 
        // to display image after call to tokenURI
        bytes memory _metaJson_start = abi.encodePacked(
            '{"name": "EXPerience NFT#',
            Strings.toString(_nftID),
            '", "description": "EXPerience NFT. Part of Ethernaut DAO bounties. Soulbound token/asset experience through EXP Token and EXPerience NFT.',
            '", "external_url": "https://github.com/SolDev-HP/EXPerience_Game"',
            ', "attributes": [{"trait_type": "EXPerience Level", "value": "',
            _expLevel,
            '"}], "owner": "'
        );

        bytes memory _metaJson_end = abi.encodePacked(
            _metaJson_start,
            _owner,
            '", "image": "',
            _imgUrl,
            '", "animation_url": "',
            _imgUrl,
            '"}'
        );
        
        tokenURI = string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(_metaJson_end)
            )
        );
    }
}