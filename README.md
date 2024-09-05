# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```
# firstnft
## 1. 主要思路
支付不少于一定数量的USDC或ETH，随机锁定一段时间，在解锁时免费mint一个NFT。若提前解锁，返还50%费用+按已锁定时间线性解锁的剩余部分
## 2. 用到的知识
- hardhat
- ERC20
- mapping、array、struct等类型
- modifier修饰符
- event
- ERC721
- random
- require等权限控制
- payable
- safeTransfer
- gas report
