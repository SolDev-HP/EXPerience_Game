// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
pragma experimental ABIEncoderV2;   // Certainly for the struct getting passed around 

import "../utils/Strings.sol";
import "../utils/Base64.sol";

// BadgeFactory that will be used by EXPerienceNFT 
// to generate badges that support necessary update passed in
// by tokenURI() function call 
library EthernautFactory {
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

    // ======================== Start - https://codepen.io/alebanfi/pen/NWyXxoL ====================================
    // =============== SVG styles and idea given by Aleta from EthernautDAO discord ================================
    // In this svg, we have two parts we need to take care of 
    // First section is color description, that has to be a mapping (selected(based on ERC20 EXP balance) => colorArray) 
    // Here's how the plan goes
    // EXP balance                  Color codings 
    // 0                            Set a special IFPS for this, we can allow having nft even if balance is 0
    // 1 - 25                       ['#ffffff', '#666666', '#333333']
    // 26 - 50                      ['#c5fccb', '#6cd4a1', '#027562']
    // 51 - 75                      ['#c6f7f5', '#30d5f2', '#074d87']
    // 76 - 100                     ['#fc9fc1', '#e61964', '#222b52'] 
    // @Todo: 100 limit has to be maintained. Confirm this once done with this implementation
    // Now every stage, svg is different + the combination of colors required depending on the level + exp display based on balance 
    // Storage needs to be used in a better manner here 

    bytes private constant _selectedCoreCommon = '</linearGradient></defs><pattern id="pattern" x="0" y="0" width="100%" height="100%"><rect x="-150%" y="0" width="200%" height="150%" fill="url(#gradient)" transform="rotate(-65)"><animate attributeType="XML" attributeName="x" from="-150%" to="50%" dur="4s" repeatCount="indefinite"/></rect><rect x="-350%" y="0" width="200%" height="150%" fill="url(#gradient)" transform="rotate(-65)"><animate attributeType="XML" attributeName="x" from="-350%" to="-150%" dur="4s" repeatCount="indefinite"/></rect></pattern>';

    bytes private constant _selectedCoreEnd = '<text x="50%" y="47%" class="base" fill="url(#pattern)" dominant-baseline="middle" text-anchor="middle" style="font-family: Josefin Sans, sans-serif;font-size:140px; ">';    
    
    function _getSVGCore(uint256 tokenAmount_) private pure returns (bytes memory) {
        // Our four cores
        // 1 - 25       Codepen(Aleta): https://codepen.io/alebanfi/pen/OJQzMaQ
        // 26 - 50      https://codepen.io/alebanfi/pen/PoQEZXQ
        // 51 - 75      https://codepen.io/alebanfi/pen/vYdpLbZ
        // 76 - 100     https://codepen.io/alebanfi/pen/NWyXxoL
        // Update: Comparison changed due to allowance of floating point 0.0x limit of EXP wallet balance 

        // Pack the string rightly if we know it's not going to be changed every. However, this should not be 
        // the case when eventually we allow custom setting of core svg generation logic 
        bytes memory _selectedCore1 = '<path fill="url(#pattern)" d="m280.2 51.8h-3.9v-9.7h4c1.7 0 3 0.5 3.8 1.5s1.2 2.1 1.2 3.3c0 0.7-0.2 1.5-0.5 2.2-0.3 0.8-0.9 1.4-1.7 1.9-0.6 0.5-1.6 0.8-2.9 0.8zm-79.1 31c0.1-12.1 0.6-25 1.9-36.8 1-9 2.8-17.2 4.9-23.8 15.7-6.5 32-10.2 48.1-10.2s32.4 3.7 48.2 10.2c2.1 6.5 3.9 14.8 4.9 23.8 1.3 11.8 1.7 24.7 1.9 36.8-33.9-3.7-76.1-3.7-109.9 0zm71.8-18h3.5v-9.6h3.9c2 0 3.6-0.4 5-1.2 1.3-0.8 2.3-1.8 2.8-3.1 0.6-1.3 0.9-2.6 0.9-4.1 0-2.5-0.8-4.5-2.4-5.9s-3.8-2.1-6.6-2.1h-7v26zm-30.3-3.4h-13.9v-8h12v-3.4h-12v-7.9h13.4v-3.3h-16.9v26h17.4v-3.4zm7.9 3.4 6.2-10.4 6.8 10.4h4.5l-8.6-13.2 8.2-12.9h-4.2l-5.9 9.9-6.5-9.9h-4.4l8.2 12.6-8.6 13.4h4.3zm-17.5 338.4v29c8.2 1.2 16 1.8 23 1.8s14.8-0.7 23-1.8v-29c-7.8 0.6-15.5 0.8-23 0.8s-15.2-0.3-23-0.8zm-143.8-25.7c0.2 0.4 0.6 1.2 1.7 2.2 2.5 2.2 6.7 5.2 12.1 8.4 10.9 6.4 26.5 13.8 44.2 20.6 21.2 8.2 45.4 15.7 67.7 20.4v-27.6c-39.5-5.1-79.9-18.3-108.4-44.5-3.6 1.2-7.3 3.4-10.3 6.4-4 4.1-6.5 9.4-7 14.1zm316.2-20.6c-28.5 26.1-68.9 39.3-108.4 44.5v27.6c22.4-4.7 46.6-12.1 67.7-20.4 17.7-6.9 33.3-14.2 44.2-20.6 5.4-3.2 9.7-6.2 12.1-8.4 1.1-1 1.5-1.8 1.7-2.2-0.5-4.7-3-10-7.2-14.1-2.9-3-6.6-5.2-10.1-6.4zm-301.9-22.9c29.3 43.3 96.8 60 152.5 60s123.2-16.7 152.5-60c39.2-57.8 32.5-151.3-0.5-214.8-17.5-33.6-47.9-66.1-82.6-86.3 0.6 3.6 1.1 7.4 1.5 11.2 1.5 13.7 1.9 28.2 2 41.3 18.7 3.2 33 7.7 39 13.7 32 32 75.5 134.7 16 224-37.7 56.5-218.3 56.5-256 0-59.5-89.3-16-192 16-224 6-6 20.3-10.6 39-13.7 0.1-13.1 0.5-27.6 2-41.3 0.4-3.8 0.9-7.5 1.5-11.2-34.7 20.2-65 52.7-82.6 86.3-32.9 63.5-39.5 156.9-0.3 214.8zm83-301.2zm-30.5 81.7c-26.6 20.6-43 114.8-33.5 146.8 16.6-61.8 32-124 107.9-161.3-7-1.1-14.1-1.6-21.2-1.6-17.2 0.1-37.2 3.7-53.2 16.1zm-49.4 242.4zm237 98.1c-1.7-0.7-3.4-1.1-4.9-1.1h-6.4v24.7h4.6c4.1 0 7.3-1 9.7-3.1s3.6-5.1 3.6-9c0-3.2-0.7-5.7-2-7.6-1.4-1.9-2.9-3.2-4.6-3.9zm29 16.8h7.8l-3.8-9.7-4 9.7zm-194.1-3.8c-1-0.8-2.2-1.1-3.7-1.1-2.1 0-3.7 0.7-5.1 2.2-1.3 1.4-2 3.3-2 5.5 0 0.5 0 1 0.1 1.2l13-4.8c-0.5-1.2-1.3-2.2-2.3-3zm79.7 0.6c-1.4-1-2.9-1.5-4.7-1.5-1.3 0-2.6 0.3-3.7 1-1.1 0.6-2 1.6-2.7 2.7-0.7 1.2-1 2.5-1 4 0 1.4 0.3 2.8 1 3.9 0.7 1.2 1.6 2.1 2.8 2.8s2.4 1.1 3.8 1.1c1.8 0 3.4-0.5 4.7-1.5s2.2-2.4 2.5-4.2v-4.4c-0.4-1.7-1.3-3-2.7-3.9zm164.1-13.3c-1.9-1.1-3.9-1.7-6.2-1.7s-4.3 0.6-6.2 1.7-3.3 2.7-4.4 4.6-1.6 4.1-1.6 6.5c0 2.3 0.5 4.4 1.6 6.4 1.1 1.9 2.6 3.5 4.5 4.6s4 1.7 6.3 1.7c2.2 0 4.3-0.6 6.1-1.7s3.3-2.7 4.3-4.6 1.6-4.1 1.6-6.4c0-2.4-0.5-4.5-1.6-6.5s-2.6-3.5-4.4-4.6zm71.7-32.2v74.9h-476v-74.9l59.3-39.5c0.5 0.5 1.1 1 1.6 1.5 3.9 3.5 8.9 6.9 15 10.5 12.1 7.1 28.5 14.7 46.8 21.9 36.7 14.3 81 26.6 115.3 26.6s78.6-12.3 115.3-26.6c18.3-7.1 34.7-14.8 46.8-21.9 6.1-3.6 11.1-7 15-10.5 0.5-0.5 1.1-1 1.6-1.5l59.3 39.5zm-409.2 30.6h23.8v-3.9h-23.8v3.9zm1.8 11.7v3.9h20.2v-3.9h-20.2zm22.6 16.8h-25v3.9h24.9v-3.9zm19.6-18.3h-6.1v-9.9h-5.1v9.9h-4.1v4h4.1v18.3h5.1v-18.3h6.1v-4zm27.2 5.8c0-2-0.7-3.6-2.1-4.8s-3.1-1.9-5.2-1.9c-2 0-3.8 0.5-5.4 1.3-1.6 0.9-2.8 2.1-3.6 3.6v-23.5h-4.9v41.8h5v-10.5c0-1.6 0.3-3 0.9-4.3s1.4-2.3 2.5-3c1-0.7 2.2-1.1 3.5-1.1 1.4 0 2.4 0.4 3.1 1.1s1.1 1.7 1.1 3v14.8h5.1v-16.5zm12.8 9.1 17.7-6.2c-0.7-3.1-2.1-5.4-4-7.2-2-1.7-4.4-2.6-7.3-2.6-2.3 0-4.4 0.5-6.3 1.6s-3.4 2.5-4.5 4.3-1.6 3.8-1.6 6c0 2.3 0.5 4.3 1.5 6.1s2.4 3.2 4.3 4.2 4 1.5 6.5 1.5c1.3 0 2.6-0.2 4-0.7s2.7-1.1 3.9-1.9l-2.3-3.7c-1.8 1.3-3.6 1.9-5.5 1.9-1.4 0-2.7-0.3-3.8-0.9-1-0.4-1.9-1.2-2.6-2.4zm37.8-15.9c-0.9 0-1.9 0.3-3.1 0.8s-2.3 1.2-3.4 2.2c-1.1 0.9-1.9 2-2.5 3.2l-0.4-5.3h-4.5v22.4h5v-10.2c0-1.4 0.4-2.8 1.1-4.1s1.8-2.3 3.1-3 2.8-1 4.4-1l0.3-5zm27.7 6.8c0-2-0.7-3.6-2.1-4.8s-3.1-1.9-5.2-1.9-3.9 0.5-5.5 1.4-2.8 2.2-3.6 3.8l-0.3-4.3h-4.5v22.4h5v-10.5c0-2.4 0.6-4.5 1.9-6s2.9-2.4 4.9-2.4c1.4 0 2.4 0.4 3.1 1.1s1.1 1.7 1.1 3v14.8h5.1v-16.6zm31.6-5.9h-4.6l-0.4 3.6c-0.9-1.3-2-2.4-3.4-3.2s-3.1-1.2-5-1.2c-2.1 0-4.1 0.5-5.8 1.5s-3.1 2.4-4.2 4.2c-1 1.8-1.5 4-1.5 6.4s0.5 4.6 1.5 6.3c1 1.8 2.3 3.1 4 4s3.6 1.4 5.8 1.4c1.9 0 3.6-0.4 5.1-1.3s2.7-1.8 3.5-2.9v3.7h5v-22.5zm29.6 0h-5v10.4c0 1.6-0.3 3-0.9 4.3s-1.4 2.3-2.4 3.1c-1 0.7-2.1 1.1-3.3 1.1-1.3 0-2.3-0.4-3-1.2-0.7-0.7-1-1.7-1.1-3v-14.7h-5v16.5c0.1 2 0.8 3.6 2.1 4.8s3 1.9 5 1.9c1.9 0 3.7-0.5 5.3-1.4 1.6-1 2.8-2.2 3.5-3.7l0.3 4.3h4.5v-22.4zm22.1 0.1h-6.1v-9.9h-5.1v9.9h-4.1v4h4.1v18.3h5.1v-18.3h6.1v-4zm40.6 3.1c0-3.6-0.7-6.9-2.2-10s-3.9-5.7-7.2-7.6c-3.3-2-7.5-2.9-12.5-2.9h-11.9v39.7h13.8c3.6 0 7-0.8 10-2.3 3-1.6 5.5-3.8 7.3-6.7 1.8-3 2.7-6.4 2.7-10.2zm37 19.2-17.9-41.3h-0.4l-17.9 41.3h7.7l3.2-7.8h13.1l3.1 7.8h9.1zm41.2-19.8c0-3.6-0.9-7-2.8-10.1s-4.3-5.6-7.5-7.5c-3.1-1.9-6.5-2.8-10.1-2.8s-7 0.9-10.1 2.8-5.6 4.3-7.4 7.5c-1.8 3.1-2.7 6.5-2.7 10.1 0 3.7 0.9 7.1 2.7 10.2s4.3 5.6 7.4 7.4 6.5 2.7 10.2 2.7c3.6 0 7-0.9 10.1-2.7s5.6-4.3 7.5-7.4c1.8-3.2 2.7-6.6 2.7-10.2z"/>';

        bytes memory _selectedCore2 = '<path fill="url(#pattern)" d="m280.2 51.8h-3.9v-9.7h4c1.7 0 3 0.5 3.8 1.5s1.2 2.1 1.2 3.3c0 0.7-0.2 1.5-0.5 2.2-0.3 0.8-0.9 1.4-1.7 1.9-0.6 0.5-1.6 0.8-2.9 0.8zm-79.1 31c0.1-12.1 0.6-25 1.9-36.8 1-9 2.8-17.2 4.9-23.8 15.7-6.5 32-10.2 48.1-10.2s32.4 3.7 48.2 10.2c2.1 6.5 3.9 14.8 4.9 23.8 1.3 11.8 1.7 24.7 1.9 36.8-33.9-3.7-76.1-3.7-109.9 0zm71.8-18h3.5v-9.6h3.9c2 0 3.6-0.4 5-1.2 1.3-0.8 2.3-1.8 2.8-3.1 0.6-1.3 0.9-2.6 0.9-4.1 0-2.5-0.8-4.5-2.4-5.9s-3.8-2.1-6.6-2.1h-7v26zm-30.3-3.4h-13.9v-8h12v-3.4h-12v-7.9h13.4v-3.3h-16.9v26h17.4v-3.4zm7.9 3.4 6.2-10.4 6.8 10.4h4.5l-8.6-13.2 8.2-12.9h-4.2l-5.9 9.9-6.5-9.9h-4.4l8.2 12.6-8.6 13.4h4.3zm197.7 221.6 38.2-45.8-14.5-72.4-34.1-25.5c16.1 44.9 21.3 97.1 10.4 143.7zm-215.2 116.8v29c8.2 1.2 16 1.8 23 1.8s14.8-0.7 23-1.8v-29c-7.8 0.6-15.5 0.8-23 0.8s-15.2-0.3-23-0.8zm-143.8-25.7c0.2 0.4 0.6 1.2 1.7 2.2 2.5 2.2 6.7 5.2 12.1 8.4 10.9 6.4 26.5 13.8 44.2 20.6 21.2 8.2 45.4 15.7 67.7 20.4v-27.6c-39.5-5.1-79.9-18.3-108.4-44.5-3.6 1.2-7.3 3.4-10.3 6.4-4 4.1-6.5 9.4-7 14.1zm-15-234.9-34.1 25.5-14.5 72.4 38.2 45.8c-10.9-46.5-5.7-98.7 10.4-143.7zm331.2 214.3c-28.5 26.1-68.9 39.3-108.4 44.5v27.6c22.4-4.7 46.6-12.1 67.7-20.4 17.7-6.9 33.3-14.2 44.2-20.6 5.4-3.2 9.7-6.2 12.1-8.4 1.1-1 1.5-1.8 1.7-2.2-0.5-4.7-3-10-7.2-14.1-2.9-3-6.6-5.2-10.1-6.4zm-301.9-22.9c29.3 43.3 96.8 60 152.5 60s123.2-16.7 152.5-60c39.2-57.8 32.5-151.3-0.5-214.8-17.5-33.6-47.9-66.1-82.6-86.3 0.6 3.6 1.1 7.4 1.5 11.2 1.5 13.7 1.9 28.2 2 41.3 18.7 3.2 33 7.7 39 13.7 32 32 75.5 134.7 16 224-37.7 56.5-218.3 56.5-256 0-59.5-89.3-16-192 16-224 6-6 20.3-10.6 39-13.7 0.1-13.1 0.5-27.6 2-41.3 0.4-3.8 0.9-7.5 1.5-11.2-34.7 20.2-65 52.7-82.6 86.3-32.9 63.5-39.5 156.9-0.3 214.8zm83-301.2zm-30.5 81.7c-26.6 20.6-43 114.8-33.5 146.8 16.6-61.8 32-124 107.9-161.3-7-1.1-14.1-1.6-21.2-1.6-17.2 0.1-37.2 3.7-53.2 16.1zm-49.4 242.4zm237 98.1c-1.7-0.7-3.4-1.1-4.9-1.1h-6.4v24.7h4.6c4.1 0 7.3-1 9.7-3.1s3.6-5.1 3.6-9c0-3.2-0.7-5.7-2-7.6-1.4-1.9-2.9-3.2-4.6-3.9zm29 16.8h7.8l-3.8-9.7-4 9.7zm-194.1-3.8c-1-0.8-2.2-1.1-3.7-1.1-2.1 0-3.7 0.7-5.1 2.2-1.3 1.4-2 3.3-2 5.5 0 0.5 0 1 0.1 1.2l13-4.8c-0.5-1.2-1.3-2.2-2.3-3zm79.7 0.6c-1.4-1-2.9-1.5-4.7-1.5-1.3 0-2.6 0.3-3.7 1-1.1 0.6-2 1.6-2.7 2.7-0.7 1.2-1 2.5-1 4 0 1.4 0.3 2.8 1 3.9 0.7 1.2 1.6 2.1 2.8 2.8s2.4 1.1 3.8 1.1c1.8 0 3.4-0.5 4.7-1.5s2.2-2.4 2.5-4.2v-4.4c-0.4-1.7-1.3-3-2.7-3.9zm164.1-13.3c-1.9-1.1-3.9-1.7-6.2-1.7s-4.3 0.6-6.2 1.7-3.3 2.7-4.4 4.6-1.6 4.1-1.6 6.5c0 2.3 0.5 4.4 1.6 6.4 1.1 1.9 2.6 3.5 4.5 4.6s4 1.7 6.3 1.7c2.2 0 4.3-0.6 6.1-1.7s3.3-2.7 4.3-4.6 1.6-4.1 1.6-6.4c0-2.4-0.5-4.5-1.6-6.5s-2.6-3.5-4.4-4.6zm71.7-32.2v74.9h-476v-74.9l59.3-39.5c0.5 0.5 1.1 1 1.6 1.5 3.9 3.5 8.9 6.9 15 10.5 12.1 7.1 28.5 14.7 46.8 21.9 36.7 14.3 81 26.6 115.3 26.6s78.6-12.3 115.3-26.6c18.3-7.1 34.7-14.8 46.8-21.9 6.1-3.6 11.1-7 15-10.5 0.5-0.5 1.1-1 1.6-1.5l59.3 39.5zm-409.2 30.6h23.8v-3.9h-23.8v3.9zm1.8 11.7v3.9h20.2v-3.9h-20.2zm22.6 16.8h-25v3.9h24.9v-3.9zm19.6-18.3h-6.1v-9.9h-5.1v9.9h-4.1v4h4.1v18.3h5.1v-18.3h6.1v-4zm27.2 5.8c0-2-0.7-3.6-2.1-4.8s-3.1-1.9-5.2-1.9c-2 0-3.8 0.5-5.4 1.3-1.6 0.9-2.8 2.1-3.6 3.6v-23.5h-4.9v41.8h5v-10.5c0-1.6 0.3-3 0.9-4.3s1.4-2.3 2.5-3c1-0.7 2.2-1.1 3.5-1.1 1.4 0 2.4 0.4 3.1 1.1s1.1 1.7 1.1 3v14.8h5.1v-16.5zm12.8 9.1 17.7-6.2c-0.7-3.1-2.1-5.4-4-7.2-2-1.7-4.4-2.6-7.3-2.6-2.3 0-4.4 0.5-6.3 1.6s-3.4 2.5-4.5 4.3-1.6 3.8-1.6 6c0 2.3 0.5 4.3 1.5 6.1s2.4 3.2 4.3 4.2 4 1.5 6.5 1.5c1.3 0 2.6-0.2 4-0.7s2.7-1.1 3.9-1.9l-2.3-3.7c-1.8 1.3-3.6 1.9-5.5 1.9-1.4 0-2.7-0.3-3.8-0.9-1-0.4-1.9-1.2-2.6-2.4zm37.8-15.9c-0.9 0-1.9 0.3-3.1 0.8s-2.3 1.2-3.4 2.2c-1.1 0.9-1.9 2-2.5 3.2l-0.4-5.3h-4.5v22.4h5v-10.2c0-1.4 0.4-2.8 1.1-4.1s1.8-2.3 3.1-3 2.8-1 4.4-1l0.3-5zm27.7 6.8c0-2-0.7-3.6-2.1-4.8s-3.1-1.9-5.2-1.9-3.9 0.5-5.5 1.4-2.8 2.2-3.6 3.8l-0.3-4.3h-4.5v22.4h5v-10.5c0-2.4 0.6-4.5 1.9-6s2.9-2.4 4.9-2.4c1.4 0 2.4 0.4 3.1 1.1s1.1 1.7 1.1 3v14.8h5.1v-16.6zm31.6-5.9h-4.6l-0.4 3.6c-0.9-1.3-2-2.4-3.4-3.2s-3.1-1.2-5-1.2c-2.1 0-4.1 0.5-5.8 1.5s-3.1 2.4-4.2 4.2c-1 1.8-1.5 4-1.5 6.4s0.5 4.6 1.5 6.3c1 1.8 2.3 3.1 4 4s3.6 1.4 5.8 1.4c1.9 0 3.6-0.4 5.1-1.3s2.7-1.8 3.5-2.9v3.7h5v-22.5zm29.6 0h-5v10.4c0 1.6-0.3 3-0.9 4.3s-1.4 2.3-2.4 3.1c-1 0.7-2.1 1.1-3.3 1.1-1.3 0-2.3-0.4-3-1.2-0.7-0.7-1-1.7-1.1-3v-14.7h-5v16.5c0.1 2 0.8 3.6 2.1 4.8s3 1.9 5 1.9c1.9 0 3.7-0.5 5.3-1.4 1.6-1 2.8-2.2 3.5-3.7l0.3 4.3h4.5v-22.4zm22.1 0.1h-6.1v-9.9h-5.1v9.9h-4.1v4h4.1v18.3h5.1v-18.3h6.1v-4zm40.6 3.1c0-3.6-0.7-6.9-2.2-10s-3.9-5.7-7.2-7.6c-3.3-2-7.5-2.9-12.5-2.9h-11.9v39.7h13.8c3.6 0 7-0.8 10-2.3 3-1.6 5.5-3.8 7.3-6.7 1.8-3 2.7-6.4 2.7-10.2zm37 19.2-17.9-41.3h-0.4l-17.9 41.3h7.7l3.2-7.8h13.1l3.1 7.8h9.1zm41.2-19.8c0-3.6-0.9-7-2.8-10.1s-4.3-5.6-7.5-7.5c-3.1-1.9-6.5-2.8-10.1-2.8s-7 0.9-10.1 2.8-5.6 4.3-7.4 7.5c-1.8 3.1-2.7 6.5-2.7 10.1 0 3.7 0.9 7.1 2.7 10.2s4.3 5.6 7.4 7.4 6.5 2.7 10.2 2.7c3.6 0 7-0.9 10.1-2.7s5.6-4.3 7.5-7.4c1.8-3.2 2.7-6.6 2.7-10.2z"/>';
        
        bytes memory _selectedCore3 = '<path fill="url(#pattern)" d="m280.2 51.8h-3.9v-9.7h4c1.7 0 3 0.5 3.8 1.5s1.2 2.1 1.2 3.3c0 0.7-0.2 1.5-0.5 2.2-0.3 0.8-0.9 1.4-1.7 1.9-0.6 0.5-1.6 0.8-2.9 0.8zm140.4 52.8c0.8 1.4 1.6 2.9 2.4 4.4l29.9 22.4-4.7-35.5c-7 5.5-15.8 8.8-25.3 8.8-0.8 0-1.6 0-2.3-0.1zm-37.8-50c1.5-6.6 4.7-12.7 9-17.7l-35.3-5.5c9.4 7 18.2 14.8 26.3 23.2zm-181.7 28.2c0.1-12.1 0.6-25 1.9-36.8 1-9 2.8-17.2 4.9-23.8 15.7-6.5 32-10.2 48.1-10.2s32.4 3.7 48.2 10.2c2.1 6.5 3.9 14.8 4.9 23.8 1.3 11.8 1.7 24.7 1.9 36.8-33.9-3.7-76.1-3.7-109.9 0zm71.8-18h3.5v-9.6h3.9c2 0 3.6-0.4 5-1.2 1.3-0.8 2.3-1.8 2.8-3.1 0.6-1.3 0.9-2.6 0.9-4.1 0-2.5-0.8-4.5-2.4-5.9s-3.8-2.1-6.6-2.1h-7v26zm-30.3-3.4h-13.9v-8h12v-3.4h-12v-7.9h13.4v-3.3h-16.9v26h17.4v-3.4zm7.9 3.4 6.2-10.4 6.8 10.4h4.5l-8.6-13.2 8.2-12.9h-4.2l-5.9 9.9-6.5-9.9h-4.4l8.2 12.6-8.6 13.4h4.3zm197.7 221.6 38.2-45.8-14.5-72.4-34.1-25.5c16.1 44.9 21.3 97.1 10.4 143.7zm-25.4-199.7c12.8 0 23-10.2 23-23s-10.2-23-23-23-23 10.2-23 23 10.2 23 23 23zm-189.8 316.5v29c8.2 1.2 16 1.8 23 1.8s14.8-0.7 23-1.8v-29c-7.8 0.6-15.5 0.8-23 0.8s-15.2-0.3-23-0.8zm-143.8-25.7c0.2 0.4 0.6 1.2 1.7 2.2 2.5 2.2 6.7 5.2 12.1 8.4 10.9 6.4 26.5 13.8 44.2 20.6 21.2 8.2 45.4 15.7 67.7 20.4v-27.6c-39.5-5.1-79.9-18.3-108.4-44.5-3.6 1.2-7.3 3.4-10.3 6.4-4 4.1-6.5 9.4-7 14.1zm-15-234.9-34.1 25.5-14.5 72.4 38.2 45.8c-10.9-46.5-5.7-98.7 10.4-143.7zm331.2 214.3c-28.5 26.1-68.9 39.3-108.4 44.5v27.6c22.4-4.7 46.6-12.1 67.7-20.4 17.7-6.9 33.3-14.2 44.2-20.6 5.4-3.2 9.7-6.2 12.1-8.4 1.1-1 1.5-1.8 1.7-2.2-0.5-4.7-3-10-7.2-14.1-2.9-3-6.6-5.2-10.1-6.4zm-301.9-22.9c29.3 43.3 96.8 60 152.5 60s123.2-16.7 152.5-60c39.2-57.8 32.5-151.3-0.5-214.8-17.5-33.6-47.9-66.1-82.6-86.3 0.6 3.6 1.1 7.4 1.5 11.2 1.5 13.7 1.9 28.2 2 41.3 18.7 3.2 33 7.7 39 13.7 32 32 75.5 134.7 16 224-37.7 56.5-218.3 56.5-256 0-59.5-89.3-16-192 16-224 6-6 20.3-10.6 39-13.7 0.1-13.1 0.5-27.6 2-41.3 0.4-3.8 0.9-7.5 1.5-11.2-34.7 20.2-65 52.7-82.6 86.3-32.9 63.5-39.5 156.9-0.3 214.8zm83-301.2zm-30.5 81.7c-26.6 20.6-43 114.8-33.5 146.8 16.6-61.8 32-124 107.9-161.3-7-1.1-14.1-1.6-21.2-1.6-17.2 0.1-37.2 3.7-53.2 16.1zm-49.4 242.4zm237 98.1c-1.7-0.7-3.4-1.1-4.9-1.1h-6.4v24.7h4.6c4.1 0 7.3-1 9.7-3.1s3.6-5.1 3.6-9c0-3.2-0.7-5.7-2-7.6-1.4-1.9-2.9-3.2-4.6-3.9zm29 16.8h7.8l-3.8-9.7-4 9.7zm-194.1-3.8c-1-0.8-2.2-1.1-3.7-1.1-2.1 0-3.7 0.7-5.1 2.2-1.3 1.4-2 3.3-2 5.5 0 0.5 0 1 0.1 1.2l13-4.8c-0.5-1.2-1.3-2.2-2.3-3zm79.7 0.6c-1.4-1-2.9-1.5-4.7-1.5-1.3 0-2.6 0.3-3.7 1-1.1 0.6-2 1.6-2.7 2.7-0.7 1.2-1 2.5-1 4 0 1.4 0.3 2.8 1 3.9 0.7 1.2 1.6 2.1 2.8 2.8s2.4 1.1 3.8 1.1c1.8 0 3.4-0.5 4.7-1.5s2.2-2.4 2.5-4.2v-4.4c-0.4-1.7-1.3-3-2.7-3.9zm164.1-13.3c-1.9-1.1-3.9-1.7-6.2-1.7s-4.3 0.6-6.2 1.7-3.3 2.7-4.4 4.6-1.6 4.1-1.6 6.5c0 2.3 0.5 4.4 1.6 6.4 1.1 1.9 2.6 3.5 4.5 4.6s4 1.7 6.3 1.7c2.2 0 4.3-0.6 6.1-1.7s3.3-2.7 4.3-4.6 1.6-4.1 1.6-6.4c0-2.4-0.5-4.5-1.6-6.5s-2.6-3.5-4.4-4.6zm71.7-32.2v74.9h-476v-74.9l59.3-39.5c0.5 0.5 1.1 1 1.6 1.5 3.9 3.5 8.9 6.9 15 10.5 12.1 7.1 28.5 14.7 46.8 21.9 36.7 14.3 81 26.6 115.3 26.6s78.6-12.3 115.3-26.6c18.3-7.1 34.7-14.8 46.8-21.9 6.1-3.6 11.1-7 15-10.5 0.5-0.5 1.1-1 1.6-1.5l59.3 39.5zm-409.2 30.6h23.8v-3.9h-23.8v3.9zm1.8 11.7v3.9h20.2v-3.9h-20.2zm22.6 16.8h-25v3.9h24.9v-3.9zm19.6-18.3h-6.1v-9.9h-5.1v9.9h-4.1v4h4.1v18.3h5.1v-18.3h6.1v-4zm27.2 5.8c0-2-0.7-3.6-2.1-4.8s-3.1-1.9-5.2-1.9c-2 0-3.8 0.5-5.4 1.3-1.6 0.9-2.8 2.1-3.6 3.6v-23.5h-4.9v41.8h5v-10.5c0-1.6 0.3-3 0.9-4.3s1.4-2.3 2.5-3c1-0.7 2.2-1.1 3.5-1.1 1.4 0 2.4 0.4 3.1 1.1s1.1 1.7 1.1 3v14.8h5.1v-16.5zm12.8 9.1 17.7-6.2c-0.7-3.1-2.1-5.4-4-7.2-2-1.7-4.4-2.6-7.3-2.6-2.3 0-4.4 0.5-6.3 1.6s-3.4 2.5-4.5 4.3-1.6 3.8-1.6 6c0 2.3 0.5 4.3 1.5 6.1s2.4 3.2 4.3 4.2 4 1.5 6.5 1.5c1.3 0 2.6-0.2 4-0.7s2.7-1.1 3.9-1.9l-2.3-3.7c-1.8 1.3-3.6 1.9-5.5 1.9-1.4 0-2.7-0.3-3.8-0.9-1-0.4-1.9-1.2-2.6-2.4zm37.8-15.9c-0.9 0-1.9 0.3-3.1 0.8s-2.3 1.2-3.4 2.2c-1.1 0.9-1.9 2-2.5 3.2l-0.4-5.3h-4.5v22.4h5v-10.2c0-1.4 0.4-2.8 1.1-4.1s1.8-2.3 3.1-3 2.8-1 4.4-1l0.3-5zm27.7 6.8c0-2-0.7-3.6-2.1-4.8s-3.1-1.9-5.2-1.9-3.9 0.5-5.5 1.4-2.8 2.2-3.6 3.8l-0.3-4.3h-4.5v22.4h5v-10.5c0-2.4 0.6-4.5 1.9-6s2.9-2.4 4.9-2.4c1.4 0 2.4 0.4 3.1 1.1s1.1 1.7 1.1 3v14.8h5.1v-16.6zm31.6-5.9h-4.6l-0.4 3.6c-0.9-1.3-2-2.4-3.4-3.2s-3.1-1.2-5-1.2c-2.1 0-4.1 0.5-5.8 1.5s-3.1 2.4-4.2 4.2c-1 1.8-1.5 4-1.5 6.4s0.5 4.6 1.5 6.3c1 1.8 2.3 3.1 4 4s3.6 1.4 5.8 1.4c1.9 0 3.6-0.4 5.1-1.3s2.7-1.8 3.5-2.9v3.7h5v-22.5zm29.6 0h-5v10.4c0 1.6-0.3 3-0.9 4.3s-1.4 2.3-2.4 3.1c-1 0.7-2.1 1.1-3.3 1.1-1.3 0-2.3-0.4-3-1.2-0.7-0.7-1-1.7-1.1-3v-14.7h-5v16.5c0.1 2 0.8 3.6 2.1 4.8s3 1.9 5 1.9c1.9 0 3.7-0.5 5.3-1.4 1.6-1 2.8-2.2 3.5-3.7l0.3 4.3h4.5v-22.4zm22.1 0.1h-6.1v-9.9h-5.1v9.9h-4.1v4h4.1v18.3h5.1v-18.3h6.1v-4zm40.6 3.1c0-3.6-0.7-6.9-2.2-10s-3.9-5.7-7.2-7.6c-3.3-2-7.5-2.9-12.5-2.9h-11.9v39.7h13.8c3.6 0 7-0.8 10-2.3 3-1.6 5.5-3.8 7.3-6.7 1.8-3 2.7-6.4 2.7-10.2zm37 19.2-17.9-41.3h-0.4l-17.9 41.3h7.7l3.2-7.8h13.1l3.1 7.8h9.1zm41.2-19.8c0-3.6-0.9-7-2.8-10.1s-4.3-5.6-7.5-7.5c-3.1-1.9-6.5-2.8-10.1-2.8s-7 0.9-10.1 2.8-5.6 4.3-7.4 7.5c-1.8 3.1-2.7 6.5-2.7 10.1 0 3.7 0.9 7.1 2.7 10.2s4.3 5.6 7.4 7.4 6.5 2.7 10.2 2.7c3.6 0 7-0.9 10.1-2.7s5.6-4.3 7.5-7.4c1.8-3.2 2.7-6.6 2.7-10.2z"/>';
    
        //bytes memory _selectedCore4 = '';
        bytes memory _selectedCore4 = abi.encodePacked(_selectedCore1, '<path fill="url(#pattern)" d="m448.2 286.4 38.2-45.8-14.5-72.4-34.1-25.5c16.1 44.9 21.3 97.1 10.4 143.7zm-374-143.8-34.1 25.5-14.5 72.4 38.2 45.8c-10.9-46.5-5.7-98.7 10.4-143.7zm32.4 214.3z"/><path fill="url(#pattern)" d="m420.6 104.6c0.8 1.4 1.6 2.9 2.4 4.4l29.9 22.4-4.7-35.5c-7 5.5-15.8 8.8-25.3 8.8-0.8 0-1.6 0-2.3-0.1zm-37.8-50c1.5-6.6 4.7-12.7 9-17.7l-35.3-5.5c9.4 7 18.2 14.8 26.3 23.2zm40 32.1c12.8 0 23-10.2 23-23s-10.2-23-23-23-23 10.2-23 23 10.2 23 23 23z"/><path fill="url(#pattern)" d="m55 66.2v68.3l18-13.5v-54.8c4.4-3 7-7.9 7-13.2 0-8.8-7.2-16-16-16s-16 7.2-16 16c0 5.3 2.6 10.2 7 13.2z"/>');

        // Return our selected core based on tokenAmount_
        if (tokenAmount_ > 0 && tokenAmount_ <= 2500)           { return _selectedCore1; }
        else if (tokenAmount_ > 2500 && tokenAmount_ <= 5000)   { return _selectedCore2; }
        else if (tokenAmount_ > 5100 && tokenAmount_ <= 7500)   { return _selectedCore3; }
        else                                                      { return _selectedCore4; }
    }

    function _preparePackedColorStops(string[3] memory _colHexs) private pure returns (bytes memory) {
        bytes memory _stop_begin = '<stop offset="';
        bytes memory _stop_mid = '%" style="stop-color:';
        bytes memory _stop_end = ';"/>';

        // Each step contains two modifications
        // first is step offset, and then at that given offset - a color 
        // This increases 100 bytes gas compared to initial strings idea 
        // but for the lack of better optimized way, this is what I ended up with 
        bytes memory stopPrep1_ = abi.encodePacked(_stop_begin, "0", _stop_mid, _colHexs[0], _stop_end); 
        // Output:
        // <stop offset="0%" style="stop-color:#ffffff;"/>

        bytes memory stopPrep2_ = abi.encodePacked(_stop_begin, "10", _stop_mid, _colHexs[1], _stop_end); 
        bytes memory stopPrep3_ = abi.encodePacked(_stop_begin, "30", _stop_mid, _colHexs[2], _stop_end); 
        bytes memory stopPrep4_ = abi.encodePacked(_stop_begin, "70", _stop_mid, _colHexs[2], _stop_end); 
        bytes memory stopPrep5_ = abi.encodePacked(_stop_begin, "90", _stop_mid, _colHexs[1], _stop_end); 
        bytes memory stopPrep6_ = abi.encodePacked(_stop_begin, "100", _stop_mid, _colHexs[0], _stop_end); 
       
        // This will prepare our color stops - 6 stops in total at 0%, 10%, 30%, 70%, 90%, and 100%
        return abi.encodePacked(stopPrep1_, stopPrep2_, stopPrep3_, stopPrep4_, stopPrep5_, stopPrep6_);
    }

    // Function responsible for returning <color stops> filled with given colors 
    // colors are based on tokenlevel that is checked upon returning the colorstops string - that is already abi encoded 
    // _PrepareSVGStopColors 
    function _prepareSVGStopPoints(uint256 tokenAmount_) private pure returns (bytes memory) {
        // Within svg, color stops are 6 
        // they start from initial color stop, goes to last, starts from last and come back to first.
        // So in total of 6 color stops, we have 3 distinct colors.
        string[3][4] memory _colors = [
            ['#ffffff', '#666666', '#333333'],      // Level 1 colors 
            ['#c5fccb', '#6cd4a1', '#027562'],      // Level 2 colors 
            ['#c6f7f5', '#30d5f2', '#074d87'],      // Level 3 colors 
            ['#fc9fc1', '#e61964', '#222b52']       // Level 4 colors 
        ];

        // Return our selected color level
        if (tokenAmount_ > 0 && tokenAmount_ <= 2500)       { return _preparePackedColorStops(_colors[0]); }
        else if (tokenAmount_ > 2500 && tokenAmount_ <= 5000) { return _preparePackedColorStops(_colors[1]); }
        else if (tokenAmount_ > 5100 && tokenAmount_ <= 7500) { return _preparePackedColorStops(_colors[2]); }
        else                                                { return _preparePackedColorStops(_colors[3]); }
    }

    // Base64 encoded version of the svg container with colors passed
    // The idea is to prepare base64 encoded image(svg) version, while adding missing parts of the svg 
    // From the container and colors_ 
    function _base64EncodeImage(uint256 _tokenAmount) private pure returns (bytes memory) {

        // Get the svg container with svg core selected based on tokenamount 
        // SVGContainer memory _svgCont = _prepareSVGContainer(_tokenAmount);
        // Get the svg color settings 
       // string memory _svgStopColors = _prepareSVGStopColors(_tokenAmount);

        // Now start packing svg using the container and colors 
        // Remember, each _svgColorStop member of Container, requires color and _svgColorEnd
        bytes memory _returning_svg_part1 = abi.encodePacked(
            '<svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="gradient" x1="100%" y1="0%" x2="0%" y2="0%">',            // Starting svg
            _prepareSVGStopPoints(_tokenAmount)
        );

        bytes memory _returning_svg = Base64.encodeBytes(abi.encodePacked(
                _returning_svg_part1,                   // Beginning of svg tag and setup
                _selectedCoreCommon,                        // common SVG core begis
                _getSVGCore(_tokenAmount),                      // SVG core part - astronaut shape/lines changes with core 
                _selectedCoreEnd,                           // common core end part 
                Strings.toString(_tokenAmount / 10 ** 2),            // Player's EXP balance ( Now to diplay accurately, reduce those borrowed 0s)
                '</text></svg>'                         // SVG End
            ));

        return abi.encodePacked("data:image/svg+xml;base64,", _returning_svg); 
    }

    // Now the main function that will handle generating actual token url 
    /// @param _nftID - NFT token ID for which this function call is happening 
    /// @param _tokenAmount - Value of total EXP Token the owner of the NFT has 
    function _generateTokenURI(uint256 _nftID, uint256 _tokenAmount, address _owner) public pure returns (string memory tokenURI) {
        // _tokenAmount going beyond expected values. As it's uint256, need to dial it down to 18 decimal 
        // This will always result in 0 for every player that has sub-1 EXP 
        // To solve this, we can increase our allow level. For example, just to be considered, have atleast 0.01 EXP or something
        // the more we dig into floating point, farther we have to reduce our divisor 
        // Let's add 0.01 limit for this 
        // This also means, every _tokenAmount comparison would be with a 10 ** 2 number 
        // If _tokenAmount is 0.01 => _tokenAmount = 1 
        // If _tokenAmount is 25.xx => _tokenAmount = 25xx 
        // so we will adjust our level calculation logic as well 
        _tokenAmount = _tokenAmount / (10 ** 16);
        // Get our image url prepared with _tokenAmount 
        bytes memory _imgUrl = _base64EncodeImage(_tokenAmount);
        // // Get experience level that can be show in the middle of the image | Disabled until we figure out what can be returned 
        // // string memory _expLevel = _getExperienceLevel(_tokenAmount);
        // // Base64Encoded HTML part to identify where the problem is - Issue: Opensea isn't viewing NFT as expected 
        string memory _base64Markup = string(abi.encodePacked(
            'data:text/html;base64,', 
            Base64.encodeBytes(abi.encodePacked(
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
            Strings.toString(_nftID),
            '',
            '", "description": "EXPerience NFT. Part of Ethernaut DAO bounties. Soulbound token/asset experience through EXP Token and EXPerience NFT.", "external_url": "https://github.com/SolDev-HP/EXPerience_Game", "attributes": [{"trait_type": "EXP Balance", "value": "',
            Strings.toString(_tokenAmount / 10 ** 2),
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
                Base64.encodeBytes(_metaJson_end)
            )
        );
    }
}