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

import { Component, OnInit } from '@angular/core';
import { Web3Service } from './services/web3.service';
import { LoggingService } from './shared/logging.service';
/**
 * @title Landing page for users
 */

@Component({
    selector: 'landing-root',
    templateUrl: './landing.component.html',
    styleUrls: ['./landing.component.css'],
})

export class LandingComponent implements OnInit {
    loading: boolean = false;
    
    constructor(
        private _web3Service: Web3Service,
        private _logger: LoggingService
    ) {}
    
    async ngOnInit() {
        // Loading contracts EXPToken and EXPerienceNFT 
        // loading state change to true
        this.loading = true;
        await this._web3Service.init();

        // Need chain id 
        const chainID = this._web3Service.chainID;

        // EXPToken contract 
        const EXPToken = await this._web3Service.loadContract(chainID, 'EXPToken');
        // EXPerienceNFT contract 
        const EXPerienceNFT = await this._web3Service.loadContract(chainID, 'EXPerienceNFT');

        // If either of the contracts are missing,
        // check further 
        if(!EXPToken || !EXPerienceNFT) {
            this._logger.log(`Either EXPToken = ${EXPToken} or EXPerienceNFT = ${EXPerienceNFT} is Invalid.`);
            return;
        } 
    }

    LoginTabTitle = "[ Logged-in ]";  
}