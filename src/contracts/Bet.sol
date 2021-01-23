// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./BethToken.sol";

contract Bet is Ownable {

    BethToken public bethToken;

    struct Match {
        string title;
        string gameName;
        string team1;
        string team2;
        uint matchDate;

        mapping (address => uint) team1UserBetAmount;
        mapping (address => uint) team2UserBetAmount;
        uint team1TotalBetAmount;
        uint team2TotalBetAmount;

        mapping (address => uint) pickedWinner;
        mapping (address => bool) isValidator;
        address[20] validators;
        uint winner;
    }

    Match actualMatch;

    uint TIME_AMOUNT = 1 minutes;

    constructor(BethToken _bethToken) public {
        bethToken = _bethToken;

        //create default empty match
        actualMatch.title = "";
        actualMatch.gameName = "";
        actualMatch.team1 = "";
        actualMatch.team2 = "";
        actualMatch.matchDate = 0;
        actualMatch.winner = 1;
        actualMatch.team1TotalBetAmount = 0;
        actualMatch.team2TotalBetAmount = 0;
    }

    uint256 validatorMinimalStack = 1000000000000000000000; //1000 tokens

    //all validators
    mapping (address => uint256) public stackingBalance;
    mapping (address => bool) public isValidator;
    address[] public validators;

    //validators on actual match
    mapping (address => bool) public isValidatingActualMatch;
    address[20] pickedValidators;

    ////////////////////////////////
    //    validators functions   //
    //////////////////////////////

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

    function punish(address _validator, uint _amount) private {
        stackingBalance[_validator] -= _amount; //punished for not voting
        if (stackingBalance[_validator] < validatorMinimalStack) {
            isValidator[_validator] = false;
        }
    }

    function rewardValidator(address _address, uint _totalBet) private {
        uint amountForValidators = SafeMath.div(_totalBet, 20); //5% for validators
        stackingBalance[_address] += SafeMath.div(amountForValidators, 20);
    }

    ////////////////////////////////
    //       Match functions     //
    //////////////////////////////

    function createMatch(string memory _title, string memory _gameName, string memory _team1, string memory _team2, uint _matchDate) public onlyOwner {
        require(actualMatch.matchDate < block.timestamp + (6*TIME_AMOUNT) && actualMatch.winner != 0, "Already a pending match"); //can't init a new match if previous was less than 6 TIME_AMOUNT ago
        require(isValidator[msg.sender], "You need to stack 1000 BETH to be a validator and propose matches !");

        //valid match parameters
        require(_matchDate > block.timestamp + (6*TIME_AMOUNT), "This match starts to early !");

        actualMatch.title = _title;
        actualMatch.gameName = _gameName;
        actualMatch.team1 = _team1;
        actualMatch.team2 = _team2;
        actualMatch.matchDate = _matchDate;
        actualMatch.winner = 0;
        actualMatch.team1TotalBetAmount = 0;
        actualMatch.team2TotalBetAmount = 0;
        resetValidators();
    }

    function resetValidators() private {
        for (uint i = 0; i < 20; i += 1) {
            actualMatch.pickedWinner[actualMatch.validators[i]] = 0;
            actualMatch.isValidator[actualMatch.validators[i]] = false;
        }
        delete actualMatch.validators;
        address[20] memory newValidators = pickValidators();
        for (uint i = 0; i < 20; i += 1) {
            actualMatch.validators[i] = newValidators[i];
            actualMatch.isValidator[actualMatch.validators[i]] = true;
        }
    }

    function pickWinner(uint _team) public {
        require(actualMatch.isValidator[msg.sender], "You are not a validator for the pending match !");
        require(actualMatch.matchDate < block.timestamp + (6*TIME_AMOUNT), "You will be able to pick a winner 6 time_amount (see const declaration) after match started !");
        require(_team == 1 || _team == 2, "Please pick a valid team : team 1 or team 2 !");
        require(actualMatch.pickedWinner[msg.sender] == 0, "You already voted !");

        actualMatch.pickedWinner[msg.sender] = _team;
    }

    function finishMatch() public {
        require(actualMatch.winner == 0, "Winner of this match already picked !");
        require(actualMatch.matchDate < block.timestamp + (6*TIME_AMOUNT), "need to wait 6 TIME_AMOUNT so validators have time to pick winners !");

        uint team1 = 0;
        uint team2 = 0;
        for (uint i = 0; i < 20; i += 1) {
            if (actualMatch.pickedWinner[actualMatch.validators[i]] == 0) {
                punish(actualMatch.validators[i], 50); //punish for not voting 50 tokens
            }
            else {
                if (actualMatch.pickedWinner[actualMatch.validators[i]] == 1) team1 += 1;
                else team2 += 1;
            }
        }

        if (team1 >= team2) actualMatch.winner = 1; // no tie for the moment implemented in later updates
        else actualMatch.winner = 2;

        for (uint i = 0; i < 20; i += 1) {
            if (actualMatch.pickedWinner[actualMatch.validators[i]] != actualMatch.winner) {
                punish(actualMatch.validators[i], 100); //punish for not voting false 100 tokens
            }
            else {
                rewardValidator(actualMatch.validators[i], actualMatch.team1TotalBetAmount + actualMatch.team2TotalBetAmount); //reward good voters with percentage of total bet
            }
        }
    }

    function betOnTeam(uint _team, uint _amount) public {
        require(_team == 1 || _team == 2, "Please bet on a valid team !");
        require(actualMatch.matchDate > block.timestamp + 1 hours, "it's to late to bet on this match !");
        if (bethToken.transferFrom(msg.sender, address(this), _amount)) {
            if (_team == 1) {
                actualMatch.team1TotalBetAmount += _amount;
                actualMatch.team1UserBetAmount[msg.sender] += _amount;
            }
            else {
                actualMatch.team2TotalBetAmount += _amount;
                actualMatch.team2UserBetAmount[msg.sender] += _amount;
            }
        }
    }

    function getReward() public {
        require(actualMatch.winner != 0, "Winner not picked yet !");
        uint ratio;
        uint amountForValidators;
        uint deservedAmount;
        if (actualMatch.winner == 1) {
            require(actualMatch.team1UserBetAmount[msg.sender] > 0, "You bet 0 on the winner, no reward available !");
            amountForValidators = actualMatch.team1TotalBetAmount / 20; //5% for validators
            ratio = (actualMatch.team1TotalBetAmount - amountForValidators) / actualMatch.team1UserBetAmount[msg.sender];
            deservedAmount = actualMatch.team2TotalBetAmount / ratio;
            bethToken.transferFrom(address(this), msg.sender, deservedAmount);
        }
        else {
            require(actualMatch.team2UserBetAmount[msg.sender] > 0, "You bet 0 on the winner, no reward available !");
            amountForValidators = actualMatch.team2TotalBetAmount / 20; //5% for validators
            ratio = (actualMatch.team2TotalBetAmount - amountForValidators) / actualMatch.team2UserBetAmount[msg.sender];
            deservedAmount = actualMatch.team1TotalBetAmount / ratio;
            bethToken.transferFrom(address(this), msg.sender, deservedAmount);
        }
    }

}
