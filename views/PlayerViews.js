import React from 'react';

const exports = {};

// Player views must be extended.
// It does not have its own Wrapper view.

exports.GetHand = class extends React.Component {
    render() {
        const { parent, playable, hand } = this.props;
        return (
            <div>
                {hand ? 'No one won! Pick another color.' : ''}
                <br />
                {!playable ? 'Please wait...' : ''}
                <br />
                <div class="rainbow-preloader">
                <div class="rainbow-stripe"></div>
                <div class="rainbow-stripe"></div>
                <div class="rainbow-stripe"></div>
                <div class="rainbow-stripe"></div>
                <div class="rainbow-stripe"></div>
                <div class="shadow"></div>
                <div class="shadow"></div>
                </div>
                <button
                    disabled={!playable}
                    onClick={() => parent.playHand('VIOLET')}
                >Violet</button>
                <button
                    disabled={!playable}
                    onClick={() => parent.playHand('INDIGO')}
                >Indigo</button>
                <button
                    disabled={!playable}
                    onClick={() => parent.playHand('BLUE')}
                >Blue</button>
                                <button
                    disabled={!playable}
                    onClick={() => parent.playHand('GREEN')}
                >Green</button>
                <button
                    disabled={!playable}
                    onClick={() => parent.playHand('YELLOW')}
                >Yellow</button>
                <button
                    disabled={!playable}
                    onClick={() => parent.playHand('ORANGE')}
                >Orange</button>
                <button
                    disabled={!playable}
                    onClick={() => parent.playHand('RED')}
                >Red</button>
            </div>
        );
    }
}

exports.WaitingForResults = class extends React.Component {
    render() {
        return (
            <div>
                Waiting for results...
            </div>
        );
    }
}

exports.Done = class extends React.Component {
    render() {
        const { outcome } = this.props;
        return (
            <div>
                Thank you for playing! The outcome of this game was:
                <br />{outcome || 'Unknown'}
            </div>
        );
    }
}

exports.Timeout = class extends React.Component {
    render() {
        return (
            <div>
                There's been a timeout. (Someone took too long, hehe.)
            </div>
        );
    }
}

export default exports;