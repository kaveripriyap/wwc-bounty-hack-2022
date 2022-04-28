'reach 0.1';

const [isColor, VIOLET, INDIGO, BLUE, GREEN, YELLOW, ORANGE, RED] = makeEnum(7);
const [isOutcome, A_WINS, B_WINS, NO_ONE] = makeEnum(3);

const winner = (playA, playB, answerArr) => {
    if (answerArr.any(x => x == playA)) return A_WINS;
    else if (answerArr.any(x => x == playB)) return B_WINS;
    else return NO_ONE;
};

const someAnswerArr = array(UInt, [GREEN, YELLOW]);
assert(winner(VIOLET, INDIGO, someAnswerArr) == NO_ONE);
assert(winner(VIOLET, GREEN, someAnswerArr) == B_WINS);
assert(winner(YELLOW, INDIGO, someAnswerArr) == A_WINS);

forall(UInt, playA =>
    forall(UInt, playB =>
        assert(isOutcome(winner(playA, playB, someAnswerArr)))));

const Player = {
    getHand: Fun([], UInt),
    seeOutcome: Fun([UInt], Null),
};

export const main = Reach.App(() => {
    const Alice = Participant('Alice', {
        ...Player,
        wager: UInt,
    });
    const Bob = Participant('Bob', {
        ...Player,
        acceptWager: Fun([UInt], Null),
    });
    init();

    Alice.only(() => {
        const wager = declassify(interact.wager);
        const playA = declassify(interact.getHand());
    });
    Alice.publish(wager, playA)
        .pay(wager);
    commit();

    Bob.only(() => {
        interact.acceptWager(wager);
        const playB = declassify(interact.getHand());
    });
    Bob.publish(playB)
        .pay(wager);

    const outcome = winner(playA, playB, someAnswerArr);
    const [forAlice, forBob] =
        outcome == 0 ? [2, 0] :
            outcome == 1 ? [0, 2] :
              /* tie      */[1, 1];
    transfer(forAlice * wager).to(Alice);
    transfer(forBob * wager).to(Bob);
    commit();

    each([Alice, Bob], () => {
        interact.seeOutcome(outcome);
    });
});