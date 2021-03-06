import React from 'react';

const exports = {};

// Player views must be extended.
// It does not have its own Wrapper view.

exports.GetHand = class extends React.Component {
    render() {
        const { parent, playable, hand, colors } = this.props;
        return (
            <div>
                {hand ? 'You lost, sorry! Try again.' : ''}
                <br />
                {!playable ? 'Please wait...' : ''}
                <br />
                <div class="container">
                    <div class="semicircle1" style={{ backgroundColor: colors[0] }}>
                        <div id="s2" class="semicircle2" style={{ backgroundColor: colors[1] }}>
                            <div id="s3" class="semicircle3" style={{ backgroundColor: colors[2] }}>
                                <div id="s4" class="semicircle4" style={{ backgroundColor: colors[3] }}>
                                    <div id="s5" class="semicircle5" style={{ backgroundColor: colors[4] }}>
                                        <div id="s6" class="semicircle6" style={{ backgroundColor: colors[5] }}>
                                            <div id="s7" class="semicircle7" style={{ backgroundColor: colors[6] }}>
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
                        color that was switched, look carefully! </h3>
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