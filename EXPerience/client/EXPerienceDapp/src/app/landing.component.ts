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
import { getEthereum } from './utils/get-ethereum.util';
/**
 * @title Landing page for users
 */

@Component({
    selector: 'landing-root',
    templateUrl: './landing.component.html',
    styleUrls: ['./landing.component.css'],
})

export class LandingComponent implements OnInit {
    player_online: boolean = false;
    button_disabled: boolean = false;
    // First tab title 
    nTabTitle = "[ Login ]";
    // Button text on first tab to login with metamask
    Login_Status = "[ Login Details ]";
    // Tabs statuses
    login_tab_status: boolean = false;      // Always visible at the start 
    play_tab_status:boolean = true;
    view_tab_status:boolean = true;
    leaderboard_tab_status:boolean = true;

    constructor(
        private _web3Service: Web3Service,
        private _logger: LoggingService
    ) {}
    
    async ngOnInit() {
        // Accessing native elements
        this.Login_Status = "[ Checking... ]";
        // Loading contracts EXPToken and EXPerienceNFT 
        const _ether = await getEthereum();
        
        // Verify if metamask is present, no meaning of going forward if it's not
        // This will change once we start incorporating more wallet support and streamline 
        // this login process a bit more 
        if(!_ether) {
            this._logger.log(`Ethereum not present. Eth obj ${_ether}`);
            this.button_disabled = true;
            this.Login_Status = "[ Install Metamask ]";
        } else {
            this.button_disabled = false;
            this.Login_Status = "[ Login With Metamask ]";
        } 
    }  

    async getWeb3Connection() {
        if(!this.player_online) {
            const _web3ServiceStatus = await this._web3Service.init();

            if(!_web3ServiceStatus) {
                return;
            }

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

            // If connection passes, open up the gates to play-zone, NFT view, and leaderboard
            this.play_tab_status = false;
            this.view_tab_status = false;
            this.leaderboard_tab_status = false;

            // Update tab status so that we can identify if user is logged in or not 
            // and what indications should be present on the frontend 
            this.nTabTitle = "[ Logged In ]";
            this.Login_Status = "[ Disconnect ]";
        }
    }
}