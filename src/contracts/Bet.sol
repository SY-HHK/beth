// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Validator.sol";
import "./@openzeppelin/contracts/math/SafeMath.sol";

contract Bet {

    Validator public validator;
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

    constructor(Validator _validator) public {
        validator = _validator;
        bethToken = _validator.bethToken();

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

    function createMatch(string memory _title, string memory _gameName, string memory _team1, string memory _team2, uint _matchDate) public {
        require(actualMatch.matchDate < block.timestamp + 3 days && actualMatch.winner != 0, "Already a pending match"); //can't init a new match if previous was less than 3 days ago
        require(validator.isValidator(msg.sender), "You need to stack 1000 BETH to be a validator and propose matches !");

        //valid match parameters
        require(_matchDate > block.timestamp + 1 days, "This match starts to early !");

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
        address[20] memory newValidators = validator.pickValidators();
        for (uint i = 0; i < 20; i += 1) {
            actualMatch.validators[i] = newValidators[i];
            actualMatch.isValidator[actualMatch.validators[i]] = true;
        }
    }

    function pickWinner(uint _team) public {
        require(actualMatch.isValidator[msg.sender], "You are not a validator for the pending match !");
        require(actualMatch.matchDate < block.timestamp + 6 hours, "You will be able to pick a winner 6 hours after match started !");
        require(_team == 1 || _team == 2, "Please pick a valid team : team 1 or team 2 !");
        require(actualMatch.pickedWinner[msg.sender] == 0, "You already voted !");

        actualMatch.pickedWinner[msg.sender] = _team;
    }

    function finishMatch() public {
        require(actualMatch.winner == 0, "Winner of this match already picked !");
        require(actualMatch.matchDate < block.timestamp + 1 days, "need to wait 1 day so validators have time to pick winners !");

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
                reward(actualMatch.validators[i], actualMatch.team1TotalBetAmount + actualMatch.team2TotalBetAmount); //reward good voters with percentage of total bet
            }
        }
    }

    // TODO implement punish in validator with owner
    function punish(address _validator, uint _amount) private {
        validator.stackingBalance(_validator) -= _amount; //punished for not voting
        if (validator.stackingBalance(_validator) < validator.validatorMinimalStack) {
            validator.isValidator(_validator) = false;
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
            require(actualMatch.team1UserBetAmount > 0, "You bet 0 on the winner, no reward available !");
            amountForValidators = SafeMath.div(actualMatch.team1TotalBetAmount, 20); //5% for validators
            ratio = SafeMath.div(actualMatch.team1TotalBetAmount - amountForValidators, actualMatch.team1UserBetAmount);
            deservedAmount = SafeMath.div(actualMatch.team2TotalBetAmount, ratio);
            bethToken.transferFrom(address(this), msg.sender, deservedAmount);
        }
        else {
            require(actualMatch.team2UserBetAmount > 0, "You bet 0 on the winner, no reward available !");
            amountForValidators = SafeMath.div(actualMatch.team2TotalBetAmount, 20); //5% for validators
            ratio = SafeMath.div(actualMatch.team2TotalBetAmount - amountForValidators, actualMatch.team2UserBetAmount);
            deservedAmount = SafeMath.div(actualMatch.team1TotalBetAmount, ratio);
            bethToken.transferFrom(address(this), msg.sender, deservedAmount);
        }
    }

}
