import React, {Component} from 'react'
import bethLogo from '../eth-logo.png'
import Result from "./Result";

class Main extends Component {

    render() {
        return (
            <div id="content" className="mt-3">

                <table className="table table-borderless text-muted text-center">
                    <thead>
                    <tr>
                        <th scope="col">Stacking Balance</th>
                        <th scope="col">Reward Balance</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td>{window.web3.utils.fromWei(this.props.stackingBalance, 'Ether')} BethToken</td>
                    </tr>
                    </tbody>
                </table>

                <div className="card mb-4">
                    <div className="card-body">
                        <h5 className="card-title text-center">Actual Match</h5>
                        <table className="table text-center">
                            <thead>
                            <tr>
                                <th scope="col">Title</th>
                                <th scope="col">Game</th>
                                <th scope="col">Team 1</th>
                                <th scope="col">Team 2</th>
                                <th scope="col">Match date</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <th>{this.props.actualMatch.title}</th>
                                <td>{this.props.actualMatch.gameName}</td>
                                <td>{this.props.actualMatch.team1}</td>
                                <td>{this.props.actualMatch.team2}</td>
                                <td>{this.props.displayDate(this.props.actualMatch.matchDate)}</td>
                            </tr>
                            </tbody>
                        </table>
                        <table className="table text-center">
                            <thead>
                            <tr>
                                <th scope="col">Beth token on team 1</th>
                                <th scope="col">Beth token on team 2</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td>{window.web3.utils.fromWei(this.props.actualMatch.team1TotalBetAmount, 'Ether')} $Beth</td>
                                <td>{window.web3.utils.fromWei(this.props.actualMatch.team2TotalBetAmount, 'Ether')} $Beth</td>
                            </tr>
                            </tbody>
                        </table>

                        <form className="mb-3" onSubmit={(event) => {
                            event.preventDefault()
                            let amount,team
                            amount = this.amount.value.toString()
                            team = this.team.value.toString()
                            amount = window.web3.utils.toWei(amount, 'Ether')
                            this.props.betOnTeam(team, amount)
                        }}>
                            <div>
                                <label className="float-left"><b>Choose a team</b></label>
                                <span className="float-right text-muted">
                                Balance: {window.web3.utils.fromWei(this.props.bethTokenBalance, 'Ether')}
                                </span>
                            </div>
                            <div className="input-group mb-4">
                                <input
                                    type="int"
                                    ref={(team) => {
                                        this.team = team
                                    }}
                                    className="form-control form-control-lg"
                                    placeholder="Team number (1/2)"
                                    required/>
                                <input
                                    type="text"
                                    ref={(amount) => {
                                        this.amount = amount
                                    }}
                                    className="form-control form-control-lg"
                                    placeholder="Amount (0+)"
                                    required/>
                                <div className="input-group-append">
                                    <div className="input-group-text">
                                        <img src={bethLogo} height='32' alt=""/>
                                        &nbsp;&nbsp;&nbsp; beth
                                    </div>
                                </div>
                            </div>
                            <button type="submit" className="btn btn-primary btn-block btn-lg">Bet!</button>
                        </form>

                        <div className="text-center">
                            <Result winner={this.props.actualMatch.winner} getReward={this.props.getReward}/>
                        </div>
                    </div>
                </div>

                <div className="card mb-4">

                    <div className="card-body">

                        <form className="mb-3" onSubmit={(event) => {
                            event.preventDefault()
                            let amount
                            amount = this.input.value.toString()
                            amount = window.web3.utils.toWei(amount, 'Ether')
                            this.props.stackTokens(amount)
                        }}>
                            <div>
                                <label className="float-left"><b>stack Tokens and become validator (1000 tokens)</b></label>
                                <span className="float-right text-muted">
                                Balance: {window.web3.utils.fromWei(this.props.bethTokenBalance, 'Ether')}
                                </span>
                            </div>
                            <div className="input-group mb-4">
                                <input
                                    type="text"
                                    ref={(input) => {
                                        this.input = input
                                    }}
                                    className="form-control form-control-lg"
                                    placeholder="0"
                                    required/>
                                <div className="input-group-append">
                                    <div className="input-group-text">
                                        <img src={bethLogo} height='32' alt=""/>
                                        &nbsp;&nbsp;&nbsp; beth
                                    </div>
                                </div>
                            </div>
                            <button type="submit" className="btn btn-primary btn-block btn-lg">stack!</button>
                        </form>
                        <button
                            type="submit"
                            className="btn btn-link btn-block btn-sm"
                            onClick={(event) => {
                                event.preventDefault()
                                let amount
                                amount = this.input.value.toString()
                                amount = window.web3.utils.toWei(amount, 'Ether')
                                this.props.unstackTokens(amount)
                            }}>
                            UN-stack...
                        </button>
                    </div>
                </div>

                <div className="card mb-4">
                    <div className="card-body">
                        <h5 className="card-title text-center">Finish previous match (only owner)</h5>

                        <form className="mb-3" onSubmit={(event) => {
                            event.preventDefault()
                            let winner
                            winner = parseInt(this.winner.value.toString(), 10)
                            this.props.pickWinner(winner)
                        }}>
                            <div className="input-group mb-4">
                                <input
                                    type="text"
                                    ref={(winner) => {
                                        this.winner = winner
                                    }}
                                    className="form-control form-control-lg"
                                    placeholder="Team number winner"
                                    required/>
                            </div>
                            <button type="submit" className="btn btn-primary btn-block btn-lg">Pick winner</button>
                        </form>

                        <h5 className="card-title text-center">Create Match</h5>

                        <form className="mb-3" onSubmit={(event) => {
                            event.preventDefault()
                            let title,gameName, team1, team2, matchDate
                            title = this.title.value.toString()
                            gameName = this.gameName.value.toString()
                            team1 = this.team1.value.toString()
                            team2 = this.team2.value.toString()
                            matchDate = parseInt(this.matchDate.value.toString(), 10)
                            this.props.createMatch(title, gameName, team1, team2, matchDate)
                        }}>
                            <div className="input-group mb-4">
                                <input
                                    type="text"
                                    ref={(title) => {
                                        this.title = title
                                    }}
                                    className="form-control form-control-lg"
                                    placeholder="Match title"
                                    required/>
                            </div>
                            <div className="input-group mb-4">
                                <input
                                    type="text"
                                    ref={(gameName) => {
                                        this.gameName = gameName
                                    }}
                                    className="form-control form-control-lg"
                                    placeholder="Match game name"
                                    required/>
                            </div>
                            <div className="input-group mb-4">
                                <input
                                    type="text"
                                    ref={(team1) => {
                                        this.team1 = team1
                                    }}
                                    className="form-control form-control-lg"
                                    placeholder="Team 1 name"
                                    required/>
                            </div>
                            <div className="input-group mb-4">
                                <input
                                    type="text"
                                    ref={(team2) => {
                                        this.team2 = team2
                                    }}
                                    className="form-control form-control-lg"
                                    placeholder="Team 2 name"
                                    required/>
                            </div>
                            <div className="input-group mb-4">
                                <input
                                    type="text"
                                    ref={(matchDate) => {
                                        this.matchDate = matchDate
                                    }}
                                    className="form-control form-control-lg"
                                    placeholder="Timestamp of match start date"
                                    required/>
                            </div>
                            <button type="submit" className="btn btn-primary btn-block btn-lg">Create match</button>
                        </form>
                    </div>
                </div>

            </div>
        );
    }
}

export default Main;
