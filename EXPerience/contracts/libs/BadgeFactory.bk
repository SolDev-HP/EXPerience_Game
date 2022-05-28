// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
pragma experimental ABIEncoderV2;   // Certainly for the struct getting passed around 

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
    // ------------ Temporary removing struct harboring our imgas
    // struct EvoStageDetails {
    //     string _evoWanderer;
    //     string _evoFighter; 
    //     string _evoRevolutionary;
    //     string _evoLegendary;
    //     // Notice hacky-fix - height:115px instead of regular 125px. Just want to fix that image inside the circle div for now :') 
    //     string _evoGod;
    // }
    // Now for colorname and color code 
    // struct ColorDetails {
    //     string _colorName;
    //     string _colorCode;
    // }

    // Define our SVG - We are capping our viewbox to 300 300 
    // SVG containers 

    // Finally found a solution to intergate css animation and svg inside an svg. Current output is satisfying 
    // with expected quality expectations matching. Still requires continuous updates and improvements
    string internal constant _svgCont_Start = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 300"> <style type="text/css"> <![CDATA[ *, *:before, *:after { box-sizing: border-box;} body { height: 100vh; background: #000;} .center { height: 100%; display: flex; align-items: center; justify-content: center; text-align: center;} .circle { position: relative; width: 200px; height: 200px; color: #fff; background: ';
    // -- between two vars -- // Circle-background - ColorDetails._colorCode
    string internal constant _svgCont_Start_P1 = '; border-radius: 50%; border: 2px solid;} .logo { font-size: 125px; line-height: 190px; vertical-align: middle;} .button { position: absolute; bottom: 0px; left: 0; right: 0; padding: 8px; font-weight: bold; text-transform: uppercase; background: ';
    // -- between two vars -- // Button-background - ColorDetails._colorCode
    string internal constant _svgCont_Start_P2 = '; border: 2px solid; animation: slide 1.4s ease-in-out infinite; cursor: pointer;} .button:hover { color: #000; background: #fff; border-color: #000;} @keyframes slide { 0% { transform: translateX(10px) } 50% {transform: translateX(-10px) } 100% { transform: translateX(10px) }} .text { position: absolute; top: 0; left: 0; width: 100%; height: 100%; font-size: 24px; font-weight: bold; text-transform: uppercase; animation: rotate 14s linear infinite; fill: #fff;} @keyframes rotate { from { transform: rotate(0); } to { transform: rotate(360deg); }} ]]> </style> <foreignObject x="0" y="0" width="300" height="300"> <div class="center" xmlns="http://www.w3.org/1999/xhtml"><div class="circle" xmlns="http://www.w3.org/1999/xhtml"><div class="logo" xmlns="http://www.w3.org/1999/xhtml">';
    // -- between two vars -- // This is where different image sandwich in - depending on what category the level lies in 
    string internal constant _scgCont_Mid1 = '</div><div class="text" xmlns="http://www.w3.org/1999/xhtml">  <svg x="0" y="0" viewBox="0 0 300 300" enable-background="new 0 0 300 300" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"> <defs> <path id="circlePath" d=" M 150, 150 m -120, 0 a 120,120 0 0,1 240,0 a 120,120 0 0,1 -240,0 "  /> </defs> <g> <text> <textPath href="#circlePath" xml:space="preserve">EXPerience NFT!                 For.EthernautDAO   </textPath></text></g></svg></div><div class="button" xmlns="http://www.w3.org/1999/xhtml">[EXP] Level - ';

    string internal constant _svgCont_End = '</div></div></div></foreignObject></svg>';

    // Get experience level based on EXP token amount being held by user 
    // The easiest I could come up with in order to prototype this
    // Now instead of simple text, we're returning another svg, this is getting exciting :D 
    // Update: Further hacky-nesssss
    function _getExperienceLevel(uint256 _tokenAmount) internal pure returns (string memory) {
        if(_tokenAmount > 0 && _tokenAmount <= 20)
            // return _evoStage._evoWanderer;
            return '<svg width="125px" height="125px" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><path fill="#fff" d="M257.65 19.033l-47.552 85.598c-51.53 16.016-91.8 57.678-105.877 110.026L33.407 252.25l69.276 38.486c5.942 26.33 18.456 50.18 35.722 69.737 5.63-7.952 12.438-15.05 20.547-21.162-19.19-22.513-30.794-51.682-30.794-83.51 0-71.074 57.838-128.488 128.912-128.488 71.077 0 128.49 57.412 128.49 128.49 0 30.006-10.234 57.65-27.408 79.583 8.525 5.88 15.612 12.795 21.413 20.592 15.176-18.532 26.235-40.563 31.77-64.692l70.263-39.035-71.826-38.13c-14.312-52.475-54.968-94.123-106.856-109.825L257.65 19.033zm.266 150.33c-17.56 0-33.686 9.02-45.902 24.647-12.217 15.626-20.09 37.754-20.09 62.373 0 26.12 9.218 49.343 22.846 65.148l10.14 11.76-15.14 3.452c-38.027 8.67-55.962 26.396-66.48 54.268-9.788 25.934-11.75 61.67-11.99 104.236h254.473c-.047-42.74-.66-79.348-9.683-105.814-9.693-28.432-27.11-46.38-67.99-54.38l-15.272-2.99 9.817-12.076c12.778-15.718 21.267-38.404 21.267-63.603 0-24.62-7.875-46.747-20.092-62.373-12.216-15.626-28.343-24.647-45.902-24.647h-.002z"/></svg>';

        else if(_tokenAmount > 20 && _tokenAmount <= 40)
            //return _evoStage._evoFighter;
            return '<svg width="125px" height="125px" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><path fill="#fff" d="M261.61 17.086c-1.54-.042-3.12.127-4.657.127-12.09 0-23.35 4.608-32.758 12.512l-47.045-9.737 25.846 40.922c-1.585 4.302-2.87 8.82-3.803 13.52L153.3 93.924l46.333 19.685c2.916 13.003 8.493 24.604 15.83 33.808-8.44 1.31-16.06 3.917-22.904 7.637l-61.8-34.916 34.474 61.038c-4.273 6.62-7.887 14.01-10.886 22.01l-72.526.675 63.283 37.34c-1.184 8.643-1.897 17.604-2.167 26.77l-65.317 18.16 66.466 18.482c1.01 11.462 2.592 22.985 4.73 34.358h22.69l-1.024-104.38 18.688-.183 1.084 110.492 1.047 15.887-60.99 22.888 63.272 11.732 2.723 41.305-55.178 20.707 57.242 10.615 1.646 24.975h45.67v-174.63h18.687v174.63h45.545l1.828-24.55 59.524-11.04-57.104-21.43 3-40.277 64.922-12.037-62.283-23.373 1.38-18.545 1.053-107.35 18.69.184-1.026 104.38h24.744c2.365-11.393 4.037-22.817 5.032-34.103l67.386-18.737-66.613-18.52c-.43-8.708-1.303-17.198-2.62-25.38l65.03-38.37-75.772-.707c-2.765-6.676-5.943-12.91-9.54-18.61l36.376-64.407-64.37 36.368c-6.687-3.91-14.017-6.706-21.995-8.207 7.72-9.313 13.61-21.154 16.66-34.523l46.73-19.853-46.266-19.653c-.84-4.22-1.943-8.307-3.307-12.217l26.566-42.065-47.68 9.87c-7.905-6.853-17.15-11.348-27.132-12.645-.5-.075-1.008-.113-1.52-.127zm-4.87 18.844c10.617 0 20.556 5.69 28.377 16.193 6.196 8.322 10.727 19.572 12.348 32.307h-31.338l.002 18.69h31.554c-1.395 13.514-6.065 25.47-12.567 34.204-7.82 10.505-17.76 16.194-28.377 16.194-10.617 0-20.556-5.69-28.377-16.194-6.502-8.733-11.172-20.69-12.566-34.205h31.642l-.002-18.69h-31.422c1.62-12.735 6.15-23.985 12.347-32.307 7.82-10.504 17.76-16.193 28.377-16.193z"/></svg>';

        else if(_tokenAmount > 40 && _tokenAmount <= 60)
            // return _evoStage._evoRevolutionary;
            return '<svg width="125px" height="125px" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><path fill="#fff" d="M195.36 23.666l28.824 95.553 89.27 69.065c-.32-.038-.642-.07-.962-.105L13.872 65.7l138.18 139.404 93.598-9.612c-.703.244-1.403.495-2.1.748v-.373l-225.812 94.45 113.344.5 31.723-30.897-12.807 30.98.266.002-62.846 153.215 43.29-42.91 14.24-40.63c.618 4.344 1.416 8.636 2.398 12.862l.36 2.896-.222-.06 12.522 92.638 11.45-41.99c25.39 35.722 65.968 60.23 113.1 63.562 2.995.212 5.975.328 8.94.366-57.247-18.434-100.216-72.73-95.63-135.846 4.28-58.87 52.44-109.197 112-110.328 3.972-.076 7.994.067 12.056.44 52.61 4.84 97.167 51.102 90.717 105.802-5 42.397-43.393 78.356-88.122 71.203-16.24-2.596-30.992-11.363-41.04-23.928-10.047-12.564-15.302-29.433-11.24-46.85 2.652-11.367 9.572-21.562 19.194-28.29 9.62-6.73 22.765-9.72 35.355-4.692h.002c7.013 2.8 12.597 8.046 16.17 15.17 1.788 3.562 3.007 7.78 2.563 12.453-.443 4.672-2.894 9.552-6.783 12.97l-12.34-14.034c.73-.64.5-.478.52-.703.02-.226-.05-1.086-.662-2.308-1.226-2.443-4.882-5.587-6.4-6.193-6.366-2.543-12.13-1.257-17.717 2.65-5.588 3.91-10.182 10.713-11.7 17.222-2.676 11.47.58 22.11 7.634 30.93 7.056 8.824 18 15.326 29.395 17.148 33.27 5.32 62.77-22.37 66.61-54.938 5.12-43.418-31.13-81.073-73.87-85.003-53.92-4.964-99.866 39.815-103.704 92.63-4.666 64.2 49.07 118.513 112.38 122.302 74.91 4.483 137.724-57.982 141.292-131.562 1.286-26.52-4.85-53.308-17.34-76.83l2.076-1.102c-20.982-58.506-67.582-155.713-67.582-155.713l-.12 61.682-49.558-84.84 7.213 50.8 33.238 53.083L195.36 23.666z"/></svg>';

        else if(_tokenAmount > 60 && _tokenAmount <= 80)
            // return _evoStage._evoLegendary;
            return '<svg viewBox="0 0 500 500" height="125" width="125" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"><path fill="#FFF" d="M188.8 20.38c-5.3 26.85 4.6 55.74 34.1 86.52 11.2-7.29 31.6-10.94 50-8.16-46-22.31-66.5-47.13-84.1-78.36zM29.19 26.62C43.56 73.08 81.09 128.8 129.6 168.3 93.51 166 49.93 153.1 18.76 143c24.96 35.2 64.17 52.9 103.34 66.3C97.13 227 66.99 245 18.66 248c54.64 19.2 107.54 8.9 131.34.7-17.9 34.9-100.72 66.2-122.31 77 53.26 4.2 121.71-11 167.01-32.9 10 24.6-1.6 53.2-10.1 77.8-1.9 4.5-3.8 8.9-5.7 13.3 5.1-3.5 10.1-7 14.9-10.6 23.6-16.2 47.8-31.9 59.5-58.8 26.1 31.2 62.7 62.1 107 85.4 17.4 22.1 28.3 49 34.2 73.8 8.3-19.1 13.8-40.2 9.7-60.3 24.5-3.6 35.6-29.7 35.5-54.4-12.6 6.2-15.1 6.3-31.2 8.2 0-10.1.6-12.5-3-28.7-10.3 8.4-21 11.2-30.8 11.8 2.1-7.6 3-19.5 3.7-27.3-13 7.1-19.2 9.7-30.1 10.8-.4-10.9-.1-20-4.1-30.4-29.6 19-48.6 1.5-68-21.3 19.8-17 96.4-21.8 95.1 7.1 14-7.3 18.8-11.2 23.6-15.9 9.1 8.5 13.4 20.9 15.1 31.4 9.3-9.4 10.3-10.5 17.1-23.8 5.7 10.1 8.8 17 10.7 30.6 8.5-6.2 15.4-13.1 19.8-21.4 7.5 15.5 8.3 16 12.4 33 17.8-13.1 21.8-31.2 22.8-47.6 2-33-.3-108.2-31-142.9 1.7 36.3-13.1 70-33.8 80.7-12.6 4.9-96.5-74.6-137.6-93.3-23.5-10.2-48.1 7.1-67.8 9.3C147 106.2 83.57 70.94 29.19 26.62zM296.1 152.8c13.3 20.9 32.2 36.9 60.1 55-19.4 2.9-65.8-6.7-77.7-24-5.5-7.9 7.1-21.3 17.6-31zM180.6 319.1c-14.4 6.2-29.2 10.9-43.8 14.3-2.4 3.6-4.6 7.1-6.7 10.5 14.8 5.3 31.5 7 44.1 2.8 3.3-9.8 5.5-19.3 6.4-27.6zm-68 19.1-10.2 1.5c-31.81 36.6-61.9 103.2-48.24 151.9h36.13c-11.12-37.7-16.53-87.1 22.31-153.4zm8.5 21.5c-5.9 11.4-10.4 22.1-13.8 32.1 12.9 6.7 29.1 8.9 44.8 8.2 4.6-10.5 9.8-21.8 14.6-33.3-15.4 1.8-31.4-1.4-45.6-7zm111.4 6.6c-12 10.5-25.2 20.3-38.9 29.6 7 34 33.4 63.4 73.9 95.7h83.3c-57.2-31.8-94.6-73.3-118.3-125.3zm-130 43.2c-2.5 11.8-3.3 22.7-3 32.9 37.3 14.2 62.5 13.5 97.5 4.1-7.2-10.3-13-21-16.9-32.3-32.7 9.4-55.4 5.7-77.6-4.7zm106.6 52.4c-38.1 10.9-68.8 13.2-107.5.3 1.8 10.4 4.5 20.1 7.5 29.4h130.1c-11.3-9.8-21.4-19.6-30.1-29.7z"/></svg>'; 

        else 
            // We still haven't checked potential cases where it's suppose to come here and doesnt, and vice-e-versa 
            // @Todo: more tests needed 
            // return _evoStage._evoGod;
            return '<svg height="115px" width="125px"  viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><path fill="#fff" d="M260.72 29.094c-54.533 0-98.97 21.704-98.97 48.312 0 26.61 44.437 48.28 98.97 48.28 54.53 0 98.967-21.67 98.967-48.28S315.25 29.094 260.72 29.094zm0 13.25c40.07 0 71.81 15.508 71.81 35.062s-31.74 35.47-71.81 35.47c-40.073 0-72.69-15.916-72.69-35.47 0-19.552 32.617-35.064 72.69-35.062zM86.53 57.187c-13.242-.094-32.234 14.59-42.31 37.688-43.3 99.244-9.583 359.695 87.874 351.97-22.002-50.492-43.8-107.983-56.72-168.75 26.337 72.494 72.33 135.58 117.845 120.186-32.017-40.185-66.048-87.265-90.032-140.342 35.016 59.175 85.37 105.853 123.03 85.5-29.742-26.583-61.568-57.524-88.812-93.25 39.647 37.38 87.092 61.34 112.25 37.75-47.69-21.07-94.37-53.67-125.062-89.75-16.312-19.176-28.195-39.39-32.72-60-2.26-10.306-2.508-20.796-.468-30.938.02-.095.043-.186.063-.28.007-.044.022-.083.03-.126 4.05-21.265 15.043-35.413 4.5-45.97-2.484-2.487-5.76-3.66-9.47-3.687zm347.658 0c-3.71.027-6.954 1.2-9.438 3.688-8.176 8.186-3.416 18.564 1.03 32.72 6.153 14.187 7.144 29.566 3.845 44.593-4.524 20.61-16.44 40.824-32.75 60-30.798 36.206-77.67 68.907-125.53 89.968 25.22 23.208 72.482-.71 112-37.97-27.245 35.728-59.07 66.67-88.814 93.25 37.662 20.355 88.016-26.323 123.033-85.498-23.985 53.077-58.016 100.157-90.032 140.343 45.515 15.395 91.478-47.69 117.814-120.186-12.918 60.768-34.686 118.26-56.688 168.75 97.457 7.726 131.142-252.725 87.844-351.97-10.077-23.097-29.07-37.78-42.313-37.686zm-22.22 73.97c-100.397 68.228-200.733 82.462-301.25 5.468 4.02 15.655 13.89 32.733 28.126 49.47 28.922 34 75.48 66.378 121.906 86.31 46.426-19.932 92.984-52.31 121.906-86.31 14.98-17.613 25.138-35.594 28.72-51.907.223-1.02.416-2.027.593-3.032z"/></svg>';
    }

    // Get evolution stage name - This whole thing gonna get revamped soon 
    function _getEvoStage(uint256 _tokenAmount) internal pure returns (string memory) {
        if(_tokenAmount > 0 && _tokenAmount <= 20)
            return 'Wanderer';
        else if(_tokenAmount > 20 && _tokenAmount <= 40)
            return 'Fighter';
        else if(_tokenAmount > 40 && _tokenAmount <= 60)
            return 'Revolutionary';
        else if(_tokenAmount > 60 && _tokenAmount <= 80)
            return 'Legendary'; 
        else 
            return 'God';
    }
    // Base64 encoded version of the svg container with styles added
    // Now our SVG container contains enough information about person holding the NFT, their EXP balance 
    // Everything on-chain (The exciting part or the part that motivates me further to develop better solutions) 
    function _base64EncodeImage(uint256 _tokenAmount, string memory _cHex) internal pure returns (string memory) {
        string memory _returning_svg = Base64.encode(abi.encodePacked(
                _svgCont_Start,
                _cHex,
                _svgCont_Start_P1,
                _cHex,
                _svgCont_Start_P2,
                _getExperienceLevel(_tokenAmount),  
                _scgCont_Mid1,
                Strings.toString(_tokenAmount),
                _svgCont_End 
            ));

        return string(abi.encodePacked("data:image/svg+xml;base64,", _returning_svg)); 
    }

    // Styles for the image 
    //function _getStyleForAnimation(string) internal pure returns (string memory) {
        // Just in case we would require this while refactoring 
    //}

    // Now the main function that will handle generating actual token url 
    /// @param _nftID - NFT token ID for which this function call is happening 
    /// @param _tokenAmount - Value of total EXP Token the owner of the NFT has 
    function _generateTokenURI(uint256 _nftID, uint256 _tokenAmount, address _owner, string memory _cName, string memory _cHex) internal pure returns (string memory tokenURI) {
        // _tokenAmount going beyond expected values. As it's uint256, need to dial it down to 18 decimal 
        _tokenAmount = _tokenAmount / (10 ** 18);
        // Get our image url prepared with _tokenAmount 
        string memory _imgUrl = _base64EncodeImage(_tokenAmount, _cHex);
        // Get experience level that can be show in the middle of the image | Disabled until we figure out what can be returned 
        // string memory _expLevel = _getExperienceLevel(_tokenAmount);
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
            ', "attributes": [{"trait_type": "EXP Balance", "value": "',
            Strings.toString(_tokenAmount),
            '"}, {"trait_type": "Colorized-by", "value": "',
            _cName,
            '"}, {"trait_type": "EXP-Stage", "value": "', 
            _getEvoStage(_tokenAmount),
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