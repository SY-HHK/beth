// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./BethToken.sol";

contract Validator {

    BethToken public bethToken;

    uint256 validatorMinimalStack = 1000000000000000000000; //1000 tokens

    mapping (address => uint256) public stackingBalance;
    mapping (address => bool) public isValidator;
    address[] public validators;

    mapping (address => bool) public isValidatingActualMatch;
    address[20] pickedValidators;

    constructor(BethToken _bethToken) public {
        bethToken = _bethToken;
    }

    function stackTokens (uint _amount) public {
        require(_amount > 0, "amount cannot be 0");

        if (bethToken.transferFrom(msg.sender, address(this), _amount)) {
            stackingBalance[msg.sender] += _amount;

            //become validator is enough stack
            if (!isValidator[msg.sender] && stackingBalance[msg.sender] > validatorMinimalStack) {
                isValidator[msg.sender] = true;
            }
        }
    }

    function unstackTokens(uint _amount) public {
        require(_amount > 0, "amount cannot be 0");
        require(stackingBalance[msg.sender] >= _amount, "Amount can't be superior of staking balance");

        if (bethToken.transferFrom(address(this), msg.sender, _amount)) {
            stackingBalance[msg.sender] -= _amount;
            if (isValidator[msg.sender] && stackingBalance[msg.sender] < validatorMinimalStack) {
                isValidator[msg.sender] = false;
            }
        }
    }

    function reindex() public {
        address[] memory oldValidators = validators;
        delete validators;
        for (uint i = 0; i < oldValidators.length; i+=1) {
            if (isValidator[oldValidators[i]]) {
                validators.push(oldValidators[i]);
            }
        }
    }

    function pickValidators() public returns (address[20] memory) {
        uint random = randomFromBlock();
        uint randomValidator;
        for (uint i = 0; i < 20; i +=1) {
            randomValidator = randomFromNumber(random);
            while(isValidatingActualMatch[validators[randomValidator]]) {
                randomValidator = randomFromNumber(random);
            }
            isValidatingActualMatch[validators[randomValidator]] = true;
            pickedValidators[i] = validators[randomValidator];
        }
        return pickedValidators;
    }

    function randomFromBlock() private view returns (uint) {
        uint randomHash = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        return randomHash % validators.length;
    }

    function randomFromNumber(uint number) private view returns (uint) {
        uint randomHash = uint(keccak256(abi.encodePacked(number, block.difficulty)));
        return randomHash % validators.length;
    }

}
