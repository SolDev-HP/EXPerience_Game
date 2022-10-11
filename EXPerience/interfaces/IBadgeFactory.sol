// BadgeFactory interface to use badgefactory functions on brownie console
// SPDX-Lincense-Identifier: MIT
pragma solidity >=0.8.0;
interface IBadgeFactory {

    // public functions within BadgeFactory
    function set_library_address(address) external;
    function get_library_address() external returns (address);
    function deploy_points_erc20(string memory, string memory) external;
    function deploy_badges_erc721_with_erc20_attached(address, address, string memory, string memory ) external;
    function get_total_points_deployments_by_owner(address) external view returns (uint256);
    function get_total_badges_deployments_by_owner(address) external view returns (uint256);
    function get_nth_points_contract_address(address, uint256) external view returns (address);
    function get_nth_badges_contract_address(address, uint256) external view returns (address);
    function get_total_points_deployers() external view returns (uint256);
    function get_total_badges_deployers() external view returns (uint256);
}