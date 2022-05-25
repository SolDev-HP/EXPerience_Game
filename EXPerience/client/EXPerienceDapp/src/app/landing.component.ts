// Here, we start our frontend to navigate towards EXPerience game play 
// + earning some EXP tokens + View your NFT change as you gain.
// Tabbular design in following way 
// 
//     --------------------------------------------------------------------
//     |   [ Login ]   |    Game     |    NFTView    |    Leaderboard     |
//     |  Wallet Conn. |   Locked    |    Locked     |       Locked       |  
//     |___ (Active)___|_____________|_______________|____________________|
// 
// Initial landing should be on [Login] tab, 
// other tabs are disabled until login has been performed 
// once you login, you can play game, view nft tab, or view leaderboard,
// and your position on the leaderboard 

import { Component } from '@angular/core';
/**
 * @title Landing page for users
 */

@Component({
    selector: 'landing-root',
    templateUrl: './landing.component.html',
    styleUrls: ['./landing.component.css'],
})

export class LandingComponent {
    
}