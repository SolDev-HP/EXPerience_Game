// Get-ethereum utility function
// get window.ethereum but wait for document to completely load 

export const getEthereum = () => {
    // According to brownie-angular-mix
    // Event listener is not reliable - dig more, why?
    // while (document.readyState !== 'complete') {
    //     await new Promise((resolve) => setTimeout(resolve, 100));
    // }
    // clearEthereum();
    return window.ethereum;
};

export const clearEthereum = () => {
    // var timeoutIDs = setTimeout(";");
    // for(var i = 0; i < timeoutIDs; i++) {
    //     clearTimeout(i);
    // }
};