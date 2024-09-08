// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is Ownable, ERC721Enumerable {
    using SafeERC20 for IERC20;

    event Mint(address indexed dst, uint tokenId);
    event SetExecutor(
        address indexed operator,
        address indexed dst,
        bool _type
    );

    mapping(address => bool) public executor;
    uint public tokenIdIndex;
    string public _baseURI_;
    address public USDC;
    uint256 public maxPreSale;
    uint saled;
    bool public stateOpen;
    uint usdcPrice;
    uint ethPrice;
    mapping(uint => uint) public releaseTime;

    constructor(
        address _USDC,
        string memory baseURI_
    ) Ownable(msg.sender) ERC721("Stake to Earn", "Stake2Earn") {
        USDC = _USDC;
        _baseURI_ = baseURI_;
        maxPreSale = 1000;
        stateOpen = false;
        usdcPrice = 3e20;
        ethPrice = 1e17;
        executor[msg.sender] = true;
        releaseTime[0] = 15 days;
        releaseTime[1] = 7 days;
        releaseTime[2] = 3 days;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURI_;
    }

    function setExecutor(address _address, bool _type) external onlyOwner {
        executor[_address] = _type;
        emit SetExecutor(msg.sender, _address, _type);
    }

    modifier onlyExecutor() {
        require(executor[msg.sender], "executor: caller is not the executor");
        _;
    }

    function setUSDC(address _USDC) public onlyExecutor returns (bool) {
        USDC = _USDC;
        return true;
    }

    function setBaseURI(string memory _str) public onlyExecutor returns (bool) {
        _baseURI_ = _str;
        return true;
    }

    function setMaxPreSale(
        uint _maxPreSale
    ) public onlyExecutor returns (bool) {
        maxPreSale = _maxPreSale;
        return true;
    }

    function setStateOpen(bool _stateOpen) public onlyExecutor returns (bool) {
        stateOpen = _stateOpen;
        return true;
    }

    function setUsdcPrice(uint _usdcPrice) public onlyExecutor returns (bool) {
        usdcPrice = _usdcPrice;
        return true;
    }

    function setEthPrice(uint _ethPrice) public onlyExecutor returns (bool) {
        ethPrice = _ethPrice;
        return true;
    }

    function setReleaseTime(
        uint lv,
        uint _releaseTime
    ) public onlyExecutor returns (bool) {
        releaseTime[lv] = _releaseTime;
        return true;
    }

    struct StakeInfo {
        uint eth_amount;
        uint usdc_amount;
        uint lv;
        uint startTime;
        bool withdrawed;
    }

    mapping(address => StakeInfo[]) public stakeMap;

    function generateRandom() public view virtual returns (uint) {
        return
            uint(
                keccak256(
                    abi.encodePacked(
                        block.prevrandao,
                        block.timestamp,
                        msg.sender
                    )
                )
            );
    }

    function deposit(uint usdc_amount_) public payable returns (bool) {
        uint eth_amount_ = msg.value;
        require(tx.origin == _msgSender(), "Only EOA");
        require(
            usdc_amount_ >= usdcPrice || eth_amount_ >= ethPrice,
            "need more USDC or ETH"
        );
        require(stateOpen, "Not open now.");
        require(saled < maxPreSale, "over saled.");
        if (usdc_amount_ > 0) {
            IERC20(address(USDC)).safeTransferFrom(
                msg.sender,
                address(this),
                usdc_amount_
            );
        }
        uint lv_ = generateRandom() % 3;
        stakeMap[msg.sender].push(
            StakeInfo({
                eth_amount: eth_amount_,
                usdc_amount: usdc_amount_,
                lv: lv_,
                startTime: block.timestamp,
                withdrawed: false
            })
        );
        return true;
    }

    function withdraw(uint id) public returns (bool) {
        require(id < stakeMap[msg.sender].length, "wrong id");
        require(!stakeMap[msg.sender][id].withdrawed, "already withdrawed");
        StakeInfo storage stakeInfo = stakeMap[msg.sender][id];
        uint usdc_returns = stakeInfo.usdc_amount;
        uint eth_returns = stakeInfo.eth_amount;
        // 先标记为已取出，避免重入攻击
        stakeInfo.withdrawed = true;
        // 锁50%，后面线性释放
        if (block.timestamp - stakeInfo.startTime < releaseTime[stakeInfo.lv]) {
            usdc_returns =
                (usdc_returns +
                    ((block.timestamp - stakeInfo.startTime) /
                        releaseTime[stakeInfo.lv]) *
                    usdc_returns) /
                2;
            eth_returns =
                (eth_returns +
                    ((block.timestamp - stakeInfo.startTime) /
                        releaseTime[stakeInfo.lv]) *
                    eth_returns) /
                2;
        }
        if (usdc_returns > 0) {
            IERC20(address(USDC)).safeTransfer(msg.sender, usdc_returns);
        }
        if (eth_returns > 0) {
            payable(msg.sender).transfer(eth_returns);
        }
        super._safeMint(msg.sender, tokenIdIndex);
        emit Mint(msg.sender, tokenIdIndex);
        tokenIdIndex += 1;
        return true;
    }
}
