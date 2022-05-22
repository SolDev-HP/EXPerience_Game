// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../utils/Strings.sol";
import "../utils/Base64.sol";

// BadgeFactory that will be used by EXPerienceNFT 
// to generate badges that support necessary update passed in
// by tokenURI() function call 
library BadgeFactory {
    // We need five svg images to put in the center, each image is a representation of the user's level's category
    // Like evolutions - certain levels at certain evolution stage 
    // Here's what I've planned - [Levels as evolutions]
    // Evo 1 - Wanderer - Level 1 to level 20
    //       - 20 possible backgrounds - can we randomize this?
    // Evo 2 - Fighter - Level 21 to Level 40
    //       - Same 20 possible backgrounds - Somethings to differenciate from previous backgrounds 
    // Evo 3 - Revolutionary - Level 41 to Level 60 
    //       - Same 20 different backgrounds 
    // Evo 4 - Legendary - Level 61 to Level 80
    // Evo 5 - God - Level 81 to Level 100 
    // @Todo: improve this code, refactor more and more and make it concise and epic 

    // ======================== Start - Custom Center SVG Setup / Allows modification to what tokenURI returns =============================
    // @Todo: Implement this, also insertion/deletion, allows custom addition of images, potential background choices
    // This is how it feels to map color name to color hex code, everything indexed so our 
    // random number can be used to pick color at an index 
    // We need hex to update nft, name for attributes 
    // struct _ColorMap {
    //     string _hexCode;
    //     string _colorName;
    // }
    // // This is like having a mapping 
    // // mapping(string => string) -> '#hex' => 'color-name'
    // // And below code to expand it just enough to store our things 
    // struct ColorCollection {
    //     mapping(uint => _ColorMap) _keyedColorMap; 
    //     uint[] _fixedKeys; 
    //     // Keeping this open allows ability to create insertInto/removeFrom functionality 
    //     // As of now, our limit is 23 colors, so _fixedKeys are supposed to be 23 
    // }
    // Similar to above, we can create evo state mapping 
    // struct _EvolutionStage {
    //     string _name;
    //     string _repImg;
    // }

    // struct EvoStageCollection {
    //     mapping(uint => _EvolutionStage) _keyedEvoStage;
    //     uint[] _fixedKeys;
    // }
    // ======================== /END =============================
    
    // Lets follow basic instict first, messy and shitty storage code but let's see what it produces
    // Our center images depending on EXP levels and their categories as mentioned above 
    string internal constant _evoWanderer = '';
    string internal constant _evoFighter = ''; 
    string internal constant _evoRevolutionary = '';
    string internal constant _evoLegendary = '';
    string internal constant _evoGod = '';

    // Now for colorname and color code 
    struct ColorDetails {
        string _colorName;
        string _colorCode;
    }

    // Define our SVG - We are capping our viewbox to 300 300 
    // SVG containers 

    // Finally found a solution to intergate css animation and svg inside an svg. Current output is satisfying 
    // with expected quality expectations matching. Still requires continuous updates and improvements
    string internal constant _svgCont_Start = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 300"> <style type="text/css"> <![CDATA[ *, *:before, *:after { box-sizing: border-box;} body { height: 100vh; background: #000;} .center { height: 100%; display: flex; align-items: center; justify-content: center; text-align: center;} .circle { position: relative; width: 200px; height: 200px; color: #fff; background: #000; border-radius: 50%; border: 2px solid;} .logo { font-size: 125px; line-height: 190px; vertical-align: middle;} .button { position: absolute; bottom: 0px; left: 0; right: 0; padding: 8px; font-weight: bold; text-transform: uppercase; background: #000; border: 2px solid; animation: slide 1.4s ease-in-out infinite; cursor: pointer;} .button:hover { color: #000; background: #fff; border-color: #fff;} @keyframes slide { 0% { transform: translateX(10px) } 50% {transform: translateX(-10px) } 100% { transform: translateX(10px) }} .text { position: absolute; top: 0; left: 0; width: 100%; height: 100%; font-size: 24px; font-weight: bold; text-transform: uppercase; animation: rotate 14s linear infinite; fill: #fff;} @keyframes rotate { from { transform: rotate(0); } to { transform: rotate(360deg); }} ]]> </style> <foreignObject x="0" y="0" width="300" height="300"> <div class="center" xmlns="http://www.w3.org/1999/xhtml"><div class="circle" xmlns="http://www.w3.org/1999/xhtml"><div class="logo" xmlns="http://www.w3.org/1999/xhtml">';
    
    string internal constant _scgCont_Mid1 = '</div><div class="text" xmlns="http://www.w3.org/1999/xhtml">  <svg x="0" y="0" viewBox="0 0 300 300" enable-background="new 0 0 300 300" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"> <defs> <path id="circlePath" d=" M 150, 150 m -120, 0 a 120,120 0 0,1 240,0 a 120,120 0 0,1 -240,0 "  /> </defs> <g> <text> <textPath href="#circlePath" xml:space="preserve">EXPerience NFT!         For.EthernautDAO         Level - ';

    string internal constant _svgCont_Mid2 = '</textPath></text></g></svg></div><div class="button" xmlns="http://www.w3.org/1999/xhtml">[EXP] Balance - ';

    string internal constant _svgCont_End = '</div></div></div></foreignObject></svg>';

    // Get experience level based on EXP token amount being held by user 
    // The easiest I could come up with in order to prototype this
    // Now instead of simple text, we're returning another svg, this is getting exciting :D 
    function _getExperienceLevel(uint256 _tokenAmount) internal pure returns (string memory) {
        if(_tokenAmount > 0 && _tokenAmount <= 20)
            return _evoWanderer;
        else if(_tokenAmount > 20 && _tokenAmount <= 40)
            return _evoFighter;
        else if(_tokenAmount > 40 && _tokenAmount <= 60)
            return _evoRevolutionary;
        else if(_tokenAmount > 60 && _tokenAmount <= 80)
            return _evoLegendary;
        else 
            // We still haven't checked potential cases where it's suppose to come here and doesnt, and vice-e-versa 
            // @Todo: more tests needed 
            return _evoGod;
    }

    // Base64 encoded version of the svg container with styles added
    // Now our SVG container contains enough information about person holding the NFT, their EXP balance 
    // Everything on-chain (The exciting part or the part that motivates me further to develop better solutions) 
    function _base64EncodeImage(uint256 _tokenAmount) internal pure returns (string memory) {
        string memory _returning_svg = Base64.encode(abi.encodePacked(
                _svgCont_Start,
                _getExperienceLevel(_tokenAmount),  
                _scgCont_Mid1,
                _getExperienceLevel(_tokenAmount),
                _svgCont_Mid2,
                Strings.toString(_tokenAmount),
                _svgCont_End 
            ));

        return string(abi.encodePacked("data:image/svg+xml;base64,", _returning_svg)); 
    }

    // Styles for the image 
    //function _getStyleForAnimation() internal pure returns (string memory) {
        // If ever required internal styles, use this function
    //}

    // Now the main function that will handle generating actual token url 
    /// @param _nftID - NFT token ID for which this function call is happening 
    /// @param _tokenAmount - Value of total EXP Token the owner of the NFT has 
    function _generateTokenURI(uint256 _nftID, uint256 _tokenAmount, address _owner) internal pure returns (string memory tokenURI) {
        // _tokenAmount going beyond expected values. As it's uint256, need to dial it down to 18 decimal 
        _tokenAmount = _tokenAmount / (10 ** 18);
        // Get our image url prepared with _tokenAmount 
        string memory _imgUrl = _base64EncodeImage(_tokenAmount);
        // Get experience level that can be show in the middle of the image 
        string memory _expLevel = _getExperienceLevel(_tokenAmount);
        // Base64Encoded HTML part to identify where the problem is - Issue: Opensea isn't viewing NFT as expected 
        string memory _base64Markup = string(abi.encodePacked(
            'data:text/html;base64,', 
            Base64.encode(abi.encodePacked(
                    '<!DOCTYPE html><html><object type="image/svg+xml" data="',
                    _imgUrl,
                    '" alt="EXPerience"></object></html>'
            ))
        ));
        
        // Json that will be returned when tokenURI function request is received 
        // This prepared the expected response format, including all the necessary data 
        // to display image after call to tokenURI
        bytes memory _metaJson_start = abi.encodePacked(
            '{ "name": "EXPerience NFT #',
            ' ',
            Strings.toString(_nftID),
            '',
            '", "description": "EXPerience NFT. Part of Ethernaut DAO bounties. Soulbound token/asset experience through EXP Token and EXPerience NFT.", ',
            '"external_url": "https://github.com/SolDev-HP/EXPerience_Game"',
            ', "attributes": [{"trait_type": "EXPerience Level", "value": "',
            _expLevel,
            '"}], "owner": "'
        );

        bytes memory _metaJson_end = abi.encodePacked(
            _metaJson_start,
            Strings.toHexString(uint160(_owner)),
            '", "image":"',
            _imgUrl,
            '", "animation_url":"',
            _base64Markup,
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