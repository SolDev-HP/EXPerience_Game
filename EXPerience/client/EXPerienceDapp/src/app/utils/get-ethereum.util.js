// Get-ethereum utility function
// get window.ethereum but wait for document to completely load 

export const getEthereum = async() => {
    // According to brownie-angular-mix
    // Event listener is not reliable - dig more, why?
    while (document.readyState !== 'complete') {
        await new Promise((resolve) => setTimeout(resolve, 100));
    }

    return window.ethereum;
};