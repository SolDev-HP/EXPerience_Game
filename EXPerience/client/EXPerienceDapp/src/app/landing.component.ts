// Here, we start our frontend to navigate towards EXPerience game play 
// + earning some EXP tokens + View your NFT change as you gain.
// Tabbular design in following way 
//
// - Initial state 
//     --------------------------------------------------------------------
//     |   [ Login ]   |    Game     |    NFTView    |    Leaderboard     |
//     |  Wallet Conn. |   Locked    |    Locked     |       Locked       |  
//     |___ (Active)___|_____________|_______________|____________________|
// 
// - After user connects metamask 
//     --------------------------------------------------------------------
//     | [ Logged-In ] |    Game     |    NFTView    |    Leaderboard     |
//     |  Wallet Conn. |   (Active)  |               |                    |  
//     |_______________|_____________|_______________|____________________|
// Initial landing should be on [Login] tab, 
// other tabs are disabled until login has been performed 
// once you login, you can play game, view nft tab, or view leaderboard,
// and your position on the leaderboard 

import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Web3Service } from './services/web3.service';
import { LoggingService } from './shared/logging.service';
import { getEthereum, clearEthereum } from './utils/get-ethereum.util';
import { Observable } from 'rxjs';
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
    // Tab index
    tab_selected_index: number = 0;
    // First tab title 
    nTabTitle = "[ Login ]";
    // Button text on first tab to login with metamask
    Login_Status = "[ Login Details ]";
    // Tabs statuses
    login_tab_status: boolean = false;      // Always visible at the start 
    play_tab_status: boolean = true;
    view_tab_status: boolean = true;
    leaderboard_tab_status: boolean = true;
    // print later
    print_later: string = "test";
    // user's nft status
    userHasNFT: boolean = false;        // Initially assume they dont have NFT, it will be updated in later in the cycle 
    // Contracts 
    EXPTokenContract: any;
    EXPerienceNFTContract: any;
    useraddress: any;
    // Until we find a better way 
    onlyOnce: boolean = false;

    constructor(
        private _web3Service: Web3Service,
        private _logger: LoggingService
    ) { }

    async ngOnInit() {
        // Accessing native elements
        this.Login_Status = "[ Checking... ]";
        // Loading contracts EXPToken and EXPerienceNFT 
        const _ether = await getEthereum();

        // Verify if metamask is present, no meaning of going forward if it's not
        // This will change once we start incorporating more wallet support and streamline 
        // this login process a bit more 
        if (!_ether) {
            this._logger.log(`Ethereum not present. Eth obj ${_ether}`);
            this.button_disabled = true;
            this.Login_Status = "[ Install Metamask ]";
        } else {
            this.button_disabled = false;
            this.Login_Status = "[ Login With Metamask ]";
        }
    }

    async getWeb3Connection() {
        if (!this.player_online) {
            const _web3ServiceStatus = await this._web3Service.init();
            if (!_web3ServiceStatus) {
                return;
            }

            // Need chain id 
            const chainID = this._web3Service.chainID;

            // EXPToken contract 
            this.EXPTokenContract = await this._web3Service.loadContract(chainID, 'EXPToken');
            // EXPerienceNFT contract 
            this.EXPerienceNFTContract = await this._web3Service.loadContract(chainID, 'EXPerienceNFT');

            // If either of the contracts are missing,
            // check further 
            if (!this.EXPTokenContract || !this.EXPerienceNFTContract) {
                this._logger.log(`Either EXPToken = ${this.EXPTokenContract} or EXPerienceNFT = ${this.EXPerienceNFTContract} is Invalid.`);
                return;
            }

            // If connection passes, open up the gates to play-zone, NFT view, and leaderboard
            this.play_tab_status = false;
            this.view_tab_status = false;
            this.leaderboard_tab_status = false;
            // Player online - wallet connected 
            this.player_online = true;

            // Update tab status so that we can identify if user is logged in or not 
            // and what indications should be present on the frontend 
            this.nTabTitle = "[ Logged In ]";
            this.Login_Status = "[ Disconnect ]";
            // Move to play tab
            this.tab_selected_index = 1;
            // Set user address viewable
            this.useraddress = this._web3Service.accounts[0];
        } else {
            // Set player online status to false 
            // Update tab status so that we can identify if user is logged in or not 
            // and what indications should be present on the frontend 
            this.nTabTitle = "[ Login ]";
            this.Login_Status = "[ Login With Metamask ]";
            this.player_online = false;

            // When disconnected, remove all tabs 
            this.play_tab_status = true;
            this.view_tab_status = true;
            this.leaderboard_tab_status = true;

            // Clear ethereum?
            clearEthereum();
            // Clear only once 
            this.onlyOnce = false;
        }
    }

    async doesUserHaveNFT() {
        if (this.player_online && !this.onlyOnce) {
            //this._logger.log(`Contract details - ${this.EXPerienceNFTContract}`);
            const userBalance = await this.EXPerienceNFTContract.methods.balanceOf(
                this._web3Service.accounts[0]).call({ from: this._web3Service.accounts[0] }).then((result) => {
                    // finally print the value that we received 
                    this._logger.log(`EXP contract address ${this.EXPerienceNFTContract}, and user is ${this._web3Service.accounts[0]} has balance - ${result}`);
                    // now if user balance if zero
                    if (result === 0) {
                        // User doesnt have nft balance
                        this.userHasNFT = false;
                    } else {
                        // Any other balance than zero is considered having nft in the wallet 
                        this.userHasNFT = true;
                    }
                    this.onlyOnce = true;
                    return this.userHasNFT;
                }, (error) => {
                    this._logger.log(`Exception occurred - ${error}`);
                    return this.userHasNFT;
                });
        }
        return this.userHasNFT;
    }
}