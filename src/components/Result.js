import React, { Component } from 'react'

class Result extends Component {

    render() {
        if (this.props.winner == 0) {
            return (
                <div>
                    <h5>Winner not picked Yet</h5>
                </div>
            )
        }
        else return (
            <div>
                <h5>Winner is team {this.props.winner}</h5>
                <form className="mb-3" onSubmit={(event) => {
                    event.preventDefault()
                    this.props.getReward()
                }}>
                <button type="submit" className="btn btn-primary">Get Reward</button>
                </form>
            </div>
        )
    }

}

export default Result