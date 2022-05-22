import React from 'react';
import AppViews from './views/AppViews';
import DeployerViews from './views/DeployerViews';
import AttacherViews from './views/AttacherViews';
import { renderDOM, renderView } from './views/render';
import './index.css';
// import './index.scss';
import * as backend from './build/index.main.mjs';
import { loadStdlib } from '@reach-sh/stdlib';
const reach = loadStdlib(process.env);
import { ALGO_MyAlgoConnect as MyAlgoConnect } from '@reach-sh/stdlib';
reach.setWalletFallback(reach.walletFallback({
    providerEnv: {
        ALGO_TOKEN: '',
        ALGO_SERVER: "https://testnet-api.algonode.cloud",
        ALGO_PORT: '',
        ALGO_INDEXER_TOKEN: '',
        ALGO_INDEXER_SERVER: "https://testnet-idx.algonode.cloud",
        ALGO_INDEXER_PORT: '',
    }, MyAlgoConnect
}));

const handToInt = {
    'VIOLET': 0, 'INDIGO': 1, 'BLUE': 2,
    'GREEN': 3, 'YELLOW': 4, 'ORANGE': 5, 'RED': 6
};
const intToColor = {
    0: 'violet', 1: 'indigo', 2: 'blue', 3: 'green', 4: 'yellow', 5:'orange', 6: 'red',
}
const intToOutcome = ['A wins!', 'B wins!', 'No one wins!'];
const { standardUnit } = reach;
const defaults = { defaultFundAmt: '10', defaultWager: '1', standardUnit };

class App extends React.Component {
    constructor(props) {
        super(props);
        this.state = { view: 'ConnectAccount', ...defaults };
    }
    async componentDidMount() {
        const acc = await reach.getDefaultAccount();
        const balAtomic = await reach.balanceOf(acc);
        const bal = reach.formatCurrency(balAtomic, 4);
        this.setState({ acc, bal });
        if (await reach.canFundFromFaucet()) {
            this.setState({ view: 'FundAccount' });
        } else {
            this.setState({ view: 'DeployerOrAttacher' });
        }
    }
    async fundAccount(fundAmount) {
        await reach.fundFromFaucet(this.state.acc, reach.parseCurrency(fundAmount));
        this.setState({ view: 'DeployerOrAttacher' });
    }
    async skipFundAccount() { this.setState({ view: 'DeployerOrAttacher' }); }
    selectAttacher() { this.setState({ view: 'Wrapper', ContentView: Attacher }); }
    selectDeployer() { this.setState({ view: 'Wrapper', ContentView: Deployer }); }
    render() { return renderView(this, AppViews); }
}

class GameMaster extends React.Component {
    random() { return reach.hasRandom.random(); }
    seeOutcome(i) { this.setState({ view: 'Done', outcome: intToOutcome[i] }); }
    getQuestion() {
        const toChange1 = Math.floor(Math.random() * 7);
        const toChange2 = Math.floor(Math.random() * 7);
        const arr = Array.from(Array(7).keys());
        [arr[toChange1], arr[toChange2]] = [arr[toChange2], arr[toChange1]];
        return arr;
    }
    checkAnswer(answer) {
        return true;
    }
}

class Player extends React.Component {
    async getHand(question) { // Fun([Array(UInt, 7)], UInt)
        const colors = question.map(num => {
            return intToColor[num];
        });
        const hand = await new Promise(resolveHandP => {
            this.setState({ view: 'GetHand', playable: true, resolveHandP, colors: colors });
        });
        this.setState({ view: 'WaitingForResults', hand });
        return hand;
    }
    seeOutcome(winner) { this.setState({ view: 'Done', outcome: winner }); }
    // informTimeout() { this.setState({ view: 'Timeout' }); }
    playHand(hand) { this.state.resolveHandP(hand); }
}

class Deployer extends GameMaster {
    constructor(props) {
        super(props);
        this.state = { view: 'SetWager' };
    }
    setWager(wager) { this.setState({ view: 'Deploy', wager }); }
    async deploy() {
        const ctc = this.props.acc.contract(backend);
        this.setState({ view: 'Deploying', ctc });
        this.wager = reach.parseCurrency(this.state.wager); // UInt
        this.deadline = { ETH: 10, ALGO: 100, CFX: 1000 }[reach.connector]; // UInt
        backend.GM(ctc, this);
        const ctcInfoStr = JSON.stringify(await ctc.getInfo());
        this.setState({ view: 'WaitingForAttacher', ctcInfoStr });
    }
    render() { return renderView(this, DeployerViews); }
}
class Attacher extends Player {
    constructor(props) {
        super(props);
        this.state = { view: 'Attach' };
    }
    attach(ctcInfoStr) {
        const ctc = this.props.acc.contract(backend, JSON.parse(ctcInfoStr));
        this.setState({ view: 'Attaching' });
        backend.Kaavi(ctc, this);
    }
    async acceptWager(wagerAtomic) { // Fun([UInt], Null)
        const wager = reach.formatCurrency(wagerAtomic, 4);
        return await new Promise(resolveAcceptedP => {
            this.setState({ view: 'AcceptTerms', wager, resolveAcceptedP });
        });
    }
    termsAccepted() {
        this.state.resolveAcceptedP();
        this.setState({ view: 'WaitingForTurn' });
    }
    render() { return renderView(this, AttacherViews); }
}

renderDOM(<App />);