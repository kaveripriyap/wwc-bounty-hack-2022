import React from 'react';

const exports = {};

// Player views must be extended.
// It does not have its own Wrapper view.

exports.GetHand = class extends React.Component {
    render() {
        const { parent, playable, hand, question } = this.props;
        return (
            <div>
                {hand ? 'No one won! Pick another color.' : ''}
                <br />
                {!playable ? 'Please wait...' : ''}
                <br />
                <div class="container">
                    <div class="semicircle1">
                        <div id="s2" class="semicircle2">
                        <div id="s3" class="semicircle3">
                            <div id="s4" class="semicircle4">
                            <div id="s5" class="semicircle5">
                                <div id="s6" class="semicircle6">
                                <div id="s7" class="semicircle7">
                                    <div id="s8" class="semicircle8">
                                    </div>
                                </div>
                                </div>
                            </div>
                            </div>
                        </div>
                        </div>
                    </div>
                </div>
                <script>
                    function initialiseQuestion() {
                        var elements = document.getElementsByClassName('container');
                        for(var i=0; i < elements.length; i++){
                            elements[i].style.backgroundColor = question[i];
                        }
                    }
                </script>
                
                <div class="container text-center">
                <p class="">
                    {question.map( item => `${item} ` ).join('')}
                </p>
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