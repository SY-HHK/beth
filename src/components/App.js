import React, {Component} from 'react'
import Web3 from 'web3'
import Beth from '../abis/Beth.json'
import BethToken from '../abis/BethToken.json'
import Navbar from './Navbar'
import Main from './Main'
import './App.css'

class App extends Component {

    async componentWillMount() {
        await this.loadWeb3()
        await this.loadBlockchainData()
    }

    async loadBlockchainData() {
        const web3 = window.web3

        const accounts = await web3.eth.getAccounts()
        this.setState({account: accounts[0]})

        const networkId = await web3.eth.net.getId()

        // Load bethToken
        const bethTokenData = BethToken.networks[networkId]
        if (bethTokenData) {
            const bethToken = new web3.eth.Contract(BethToken.abi, bethTokenData.address)
            this.setState({bethToken})
            let bethTokenBalance = await bethToken.methods.balanceOf(this.state.account).call()
            this.setState({bethTokenBalance: bethTokenBalance.toString()})
        } else {
            window.alert('BethToken contract not deployed to detected network.')
        }

        // Load Beth
        const bethData = Beth.networks[networkId]
        if (bethData) {
            const beth = new web3.eth.Contract(Beth.abi, bethData.address)
            this.setState({beth})
            let stackingBalance = await beth.methods.stackingBalance(this.state.account).call()
            this.setState({stackingBalance: stackingBalance.toString()})
            let actualMatch = await beth.methods.actualMatch().call()
            this.setState({actualMatch:actualMatch})
        } else {
            window.alert('Beth contract not deployed to detected network.')
        }

        this.setState({loading: false})
    }

    async loadWeb3() {
        if (window.ethereum) {
            window.web3 = new Web3(window.ethereum)
            await window.ethereum.enable()
        } else if (window.web3) {
            window.web3 = new Web3(window.web3.currentProvider)
        } else {
            window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
        }
    }

    stackTokens = (amount) => {
        this.setState({loading: true})
        this.state.bethToken.methods.approve(this.state.beth._address, amount).send({from: this.state.account}).on('transactionHash', (hash) => {
            this.state.beth.methods.stackTokens(amount).send({from: this.state.account}).on('transactionHash', (hash) => {
                this.setState({loading: false})
            })
        })
    }

    unstackTokens = (amount) => {
        this.setState({loading: true})
        this.state.beth.methods.unstackTokens(amount).send({from: this.state.account}).on('transactionHash', (hash) => {
            this.setState({loading: false})
        })
    }

    createMatch = (title, gameName, team1, team2, matchDate) => {
        this.state({loading: true});
        this.state.methods.createMatch(title, gameName, team1, team2, matchDate).send({from: this.state.account}).on('transactionHash', (hash) => {
            this.setState({loading: false})
        })
    }

    finishMatch = () => {
        this.state({loading: true});
        this.state.methods.finishMatch().send({from: this.state.account}).on('transactionHash', (hash) => {
            this.setState({loading: false})
        })
    }

    pickWinner = (teamNumber) => {
        this.state({loading: true});
        this.state.methods.pickWinner(teamNumber).send({from: this.state.account}).on('transactionHash', (hash) => {
            this.setState({loading: false})
        })
    }

    betOnTeam = (teamNumber, amount) => {
        this.setState({loading: true})
        this.state.bethToken.methods.approve(this.state.beth._address, amount).send({from: this.state.account}).on('transactionHash', (hash) => {
            this.state.beth.methods.betOnTeam(teamNumber, amount).send({from: this.state.account}).on('transactionHash', (hash) => {
                this.setState({loading: false})
            })
        })
    }

    getReward = () => {
        this.state({loading: true});
        this.state.methods.getReward().send({from: this.state.account}).on('transactionHash', (hash) => {
            this.setState({loading: false})
        })
    }

    reindex = () => {
        this.state({loading: true});
        this.state.methods.reindex().send({from: this.state.account}).on('transactionHash', (hash) => {
            this.setState({loading: false})
        })
    }

    displayDate = (timestamp) => {
        let date = new Date(timestamp * 1000);
        return date.getUTCDate()+'/'+(date.getUTCMonth()+1)+'/'+date.getFullYear()+' '+date.getUTCHours()+':'+date.getUTCMinutes();
    }

    constructor(props) {
        super(props)
        this.state = {
            account: '0x0',
            bethToken: {},
            beth: {},
            bethTokenBalance: '0',
            stackingBalance: '0',
            actualMatch:{},
            loading: true
        }
    }

    render() {
        let content
        if (this.state.loading) {
            content = <p id="loader" className="text-center">Loading...</p>
        } else {
            content = <Main
                bethTokenBalance={this.state.bethTokenBalance}
                stackingBalance={this.state.stackingBalance}
                actualMatch={this.state.actualMatch}
                stackTokens={this.stackTokens}
                unstackTokens={this.stackTokens}
                betOnTeam={this.betOnTeam}
                displayDate={this.displayDate}
            />
        }

        return (
            <div>
                <Navbar account={this.state.account}/>
                <div className="container-fluid mt-5">
                    <div className="row">
                        <main role="main" className="col-lg-12 ml-auto mr-auto" style={{maxWidth: '600px'}}>
                            <div className="content mr-auto ml-auto">
                                <a
                                    href=""
                                    target="_blank"
                                    rel="noopener noreferrer"
                                >
                                </a>

                                {content}

                            </div>
                        </main>
                    </div>
                </div>
            </div>
        );
    }
}

export default App;
