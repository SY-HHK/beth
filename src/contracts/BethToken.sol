// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BethToken is ERC20 {

    uint256 initialSupply = 1000000000000000000000000; //1m

    constructor() public ERC20("bethToken", "BETH") {
        _mint(msg.sender, initialSupply);
    }
}
