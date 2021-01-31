import React, {Component} from 'react'
import bethLogo from '../eth-logo.png'

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
                            Create BET
                        </button>
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
                                <label className="float-left"><b>stack Tokens</b></label>
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

            </div>
        );
    }
}

export default Main;
