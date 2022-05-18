// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity >=0.8.0;

import "../../interfaces/IERC721.sol";
import "../../interfaces/extensions/IERC721Metadata.sol";
import "../utils/Context.sol";
import "../introspection/local/ERC165Storage.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165Storage, IERC721, IERC721Metadata {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _tokenToOwnerMap;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Errors 
    error OperationNotAllowed();
    error TempDisabled();

    // No token approvals - This is for soulbound nft
    // No mapping from owner to operator approvals

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;

        // Reporting supported interfaces 
        _registerInterface(type(IERC721).interfaceId);
        _registerInterface(type(IERC721Metadata).interfaceId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Storage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     * It'll always be between 0 and 1. We'll limit single nft per address
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _tokenToOwnerMap[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     * - Change to reflect on-chain generative ASCII art 
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId)) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     * Implement this in EXPerience - Badge contract
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     * Restricted
     */
    function approve(address, uint256) public virtual override {
        revert OperationNotAllowed();
    }

    /**
     * @dev See {IERC721-getApproved}.
     * Restricted
     */
    function getApproved(uint256) public view virtual override returns (address) {
        revert OperationNotAllowed();
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     * Restricted
     */
    function setApprovalForAll(address, bool) public virtual override {
        revert OperationNotAllowed();
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     * Restricted
     */
    function isApprovedForAll(address, address) public view virtual override returns (bool) {
        revert OperationNotAllowed();
    }

    /**
     * @dev See {IERC721-transferFrom}.
     * Restricted
     */
    function transferFrom(address, address, uint256) public virtual override {
        revert OperationNotAllowed();
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     * Restricted
     */
    function safeTransferFrom(address, address, uint256) public virtual override {
        revert OperationNotAllowed();
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     * Restricted
     */
    function safeTransferFrom(address, address, uint256, bytes memory) public virtual override {
        revert OperationNotAllowed();
    }

    /**
     * @dev These internal functions are not implemented as we don't need them right now.
     * When Soul and Soul-Constellation expands, we will revisit these functions to allow certain capaibilties
     * - Allow transfer only after certain period of time (temporary soulbound)
     * - Ability to convert into soulbound if held long enough 
     * - much more coming from this paper: Decentralized Society: Finding Web3’s Soul (By E. Glen Weyl, Puja Ohlhaver, Vitalik Buterin)
     */

    // function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual;
    // function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool);
    // function _transfer(address from, address to, uint256 tokenId ) internal virtual;
    // function _approve(address to, uint256 tokenId) internal virtual;
    // function _setApprovalForAll(address owner, address operator, bool approved) internal virtual;


    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokenToOwnerMap[tokenId] != address(0);
    }


    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _mint(to, tokenId);
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory
    ) internal virtual {
        _mint(to, tokenId);
        // Could perform require(_checkOnERC721Received()) here,
        // But it's left for future improvements 
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     * 
     * - We limit minting single NFT to single address here by adding a condition 
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        require(_balances[to] == 0, "ERC721: Only one EXPerienceViewer (NFT) per address");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _tokenToOwnerMap[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     * 
     * - At the moment, let's not think about any burning mechanism
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256) internal virtual {
        revert TempDisabled();
        // address owner = ERC721.ownerOf(tokenId);

        // _beforeTokenTransfer(owner, address(0), tokenId);

        // // Clear approvals
        // _approve(address(0), tokenId);

        // _balances[owner] -= 1;
        // delete _owners[tokenId];

        // emit Transfer(owner, address(0), tokenId);

        // _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}