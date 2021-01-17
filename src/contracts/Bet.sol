// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Validator.sol";

contract Bet {

    Validator public validator;

    struct Match {
        string title;
        string gameName;
        string team1;
        string team2;
        uint matchDate;
        mapping (address => uint) pickedWinner;
        mapping (address => bool) isValidator;
        address[20] validators;
        uint winner;
    }

    Match actualMatch;

    constructor(Validator _validator) public {
        validator = _validator;

        //create default empty match
        actualMatch.title = "";
        actualMatch.gameName = "";
        actualMatch.team1 = "";
        actualMatch.team2 = "";
        actualMatch.matchDate = 0;
        actualMatch.winner = 0;
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

        actualMatch.pickedWinner[msg.sender] = team;
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
        }
    }

    function punish(address _validator, uint _amount) private {
        validator.stackingBalance(_validator) -= _amount; //punished for not voting
        if (validator.stackingBalance(_validator) < validator.validatorMinimalStack) {
            validator.isValidator(_validator) = false;
        }
    }

}
