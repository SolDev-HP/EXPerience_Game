// Web3 service, that will be provided to every component in the app module 
// This has to verify whether user is logged in or not
// Accordingly display or hide the "login through metamask" button 
import { Injectable } from "@angular/core";
// We also need our map.json that has all the contract that we've deployed on rinkeby/ropsten/dev-net
import * as _map from '../../artifacts/deployments/map.json';
// Get web3 and provider 
import { getWeb3 } from '../utils/get-web3.util';
import { getEthereum } from '../utils/get-ethereum.util';
import { LoggingService } from "../shared/logging.service";


@Injectable({
    providedIn: 'root',
})
export class Web3Service {
    private _web3: any;                         // Web3 service provider 
    private _accounts: any;                     // Connected accounts 
    private _chainId: number | string = 0;      // Which chainId we are connected to 

    constructor(private _logger : LoggingService) {}

    // You *need* to call this function
    async init() {
        // Get network  provider and web3 instance 
        const web3 = await getWeb3();           

        // Getting accounts
        try {
            const ethereum = await getEthereum();
            ethereum.enable();
            this._logger.log("Ethereum enabled - " + ethereum);
        } catch (e) {
            this._logger.log("Could not enable accounts. Try again/Check this further. Exception Details - " + e);
        }

        // Get user's accounts 
        const accounts = await web3.eth.getAccounts();

        // Get current chain ID
        // Currently only on rinkeby - so revert if rinkeby/development not found 
        const chainid = parseInt(await web3.eth.getChainId());

        this._web3 = web3;
        this._accounts = accounts;
        this._chainId = chainid;

        return { web3, accounts, chainid };
    }

    // Logic to load the contract, get the most recent deployment on rinkeby 
    // from the map.json file so that we have an address to interface with 
    async loadContract(chain: string | number, contractName: string) {
        const web3 = this._web3;
        const map: any = _map;

        // Get address of the most recent deployment 
        let address;
        try {
            address = map[chain][contractName][0];  // latest contract on [0]
        } catch (e) {
            this._logger.log("Couldn't find any deployed contract at " + contractName + " on the chainid " + chain + "\nException Details: " + e);
            return undefined;
        }

        // If contract successfully loaded, 
        // load contract artifacts to find abi 
        let contractArtifacts;
        try {
            contractArtifacts = await import(`../../artifacts/${chain}/${address}.json`);
        } catch (e) {
            this._logger.log(`Failed to load contract artifacts from ../../artifacts/${chain}/${address}`);
            return undefined;
        }

        return new web3.eth.Contract(contractArtifacts.abi, address);
    }

    // Get web3 instance 
    get web3(): any {
        return this._web3;
    }

    get accounts(): any {
        return this._accounts;
    }

    get chainID(): number | string {
        if(this._chainId === 3) {
            return 3;
        } else if (this._chainId === 5777) {
            return 'ganache-cli';
        } 
        return 0;
    }
}