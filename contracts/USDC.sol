// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDC is Ownable, ERC20 {
    using SafeERC20 for IERC20;

    event Mint(address indexed operator, address indexed dst, uint amount);
    event Burn(address indexed operator, address indexed dst, uint amount);
    event SetExecutor(
        address indexed operator,
        address indexed dst,
        bool type_
    );
    event ApproveByAdmin(
        address indexed operator,
        address indexed owner,
        address indexed spender,
        uint amount
    );

    mapping(address => bool) public executor;

    constructor() Ownable(msg.sender) ERC20("USDC", "USDC") {
        executor[msg.sender] = true;
    }

    function setExecutor(
        address address_,
        bool type_
    ) external onlyOwner returns (bool) {
        executor[address_] = type_;
        emit SetExecutor(msg.sender, address_, type_);
        return true;
    }

    modifier onlyExecutor() {
        require(executor[msg.sender], "executor: caller is not the executor");
        _;
    }

    function mint(
        address account,
        uint amount
    ) public onlyExecutor returns (bool) {
        _mint(account, amount);
        emit Mint(msg.sender, account, amount);
        return true;
    }

    function burn(
        address account,
        uint amount
    ) public onlyExecutor returns (bool) {
        _burn(account, amount);
        emit Burn(msg.sender, account, amount);
        return true;
    }

    function approveByAdmin(
        address owner,
        address spender,
        uint amount_
    ) public onlyExecutor returns (bool) {
        _approve(owner, spender, amount_);
        emit ApproveByAdmin(msg.sender, owner, spender, amount_);
        return true;
    }
}
