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
                <div class="container">
                    <div class="semicircle1">
                        <div class="semicircle2">
                        <div class="semicircle3">
                            <div class="semicircle4">
                            <div class="semicircle5">
                                <div class="semicircle6">
                                <div class="semicircle7">
                                    <div class="semicircle8">
                                    </div>
                                </div>
                                </div>
                            </div>
                            </div>
                        </div>
                        </div>
                    </div>
                </div>
                <div class="container text-center">
                <h3 class=""> Choose the 
                    <span class="a">r</span>
                    <span class="b">a</span>
                    <span class="c">i</span>
                    <span class="d">n</span>
                    <span class="e">b</span>
                    <span class="f">o</span>
                    <span class="a">w</span> 
                    color that was switched! </h3>
                </div>
                <button class="rainbow rainbow-1"
                    disabled={!playable}
                    onClick={() => parent.playHand('VIOLET')}
                >Violet</button>
                <button class="rainbow rainbow-2"
                    disabled={!playable}
                    onClick={() => parent.playHand('INDIGO')}
                >Indigo</button>
                <button class="rainbow rainbow-3"
                    disabled={!playable}
                    onClick={() => parent.playHand('BLUE')}
                >Blue</button>
                <button class="rainbow rainbow-4"
                    disabled={!playable}
                    onClick={() => parent.playHand('GREEN')}
                >Green</button>
                <button class="rainbow rainbow-5"
                    disabled={!playable}
                    onClick={() => parent.playHand('YELLOW')}
                >Yellow</button>
                <button class="rainbow rainbow-6"
                    disabled={!playable}
                    onClick={() => parent.playHand('ORANGE')}
                >Orange</button>
                <button class="rainbow rainbow-7"
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