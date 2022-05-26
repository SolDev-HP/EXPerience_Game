// Import web3 and check web3 instance 
import Web3 from 'web3';
import { getEthereum } from './get-ethereum.util';
import { LoggingService } from '../shared/logging.service';

export const getWeb3 = async() => {
    // get the ethereum first 
    const ethereum = await getEthereum();
    let web3;
    let logger = new LoggingService();

    if(ethereum) {
        // We have a provider, get web3 instance 
        web3 = new Web3(ethereum);
        logger.log("Ethereum Provider");
    } else if (window.web3) {
        // So web3.js ?
        web3 = window.web3;
        logger.log("Web3 Provider");
    } else {
        // Dev net 
        // Ganache-cli rpc when running local eth chain 
        const provider = new Web3.provider.HttpProvider('http://127.0.0.1:8545');
        web3 = new Web3(provider);
        logger.log("Development");
    }

    // So now we return the instance of the web3
    // logger.log(web3);
    return web3;
};