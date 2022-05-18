// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
interface ImpMe {
    function func1(string memory) external returns (bool);
    function func2() external returns (string memory);
}

interface IERC20Metadata {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract BaseCon is ImpMe {
    function supportedInterfacesBySelectors() external view returns (bytes4) {
        return this.supportedInterfacesBySelectors.selector ^ this.func1.selector ^ this.func2.selector;
    }

    function supportedInterfaces() external view returns (bytes4) {
        return this.func1.selector ^ this.func2.selector;               // Should yield same results as type(ImpMe).interfaceId
    }
    function supportsImpMe() external view returns (bytes4) {
        return type(ImpMe).interfaceId;
    }
    function func1(string memory) external view returns (bool) { }
    function func2() external returns (string memory) { }
}

contract BaseTwo is IERC20Metadata {
    function baseTwoInterface() public view returns (bytes4) {
        return type(IERC20Metadata).interfaceId;
    }

    function name() external view returns (string memory) { }
    function symbol() external view returns (string memory) { }
    function decimals() external view returns (uint8) { }
}