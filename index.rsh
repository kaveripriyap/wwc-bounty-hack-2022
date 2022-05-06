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
    ...hasRandom,
    getHand: Fun([], UInt),
    seeOutcome: Fun([UInt], Null),
    informTimeout: Fun([], Null),
};

export const main = Reach.App(() => {
    const Alice = Participant('Alice', {
        ...Player,
        wager: UInt,
        deadline: UInt,
    });
    const Bob = Participant('Bob', {
        ...Player,
        acceptWager: Fun([UInt], Null),
    });
    init();

    const informTimeout = () => {
        each([Alice, Bob], () => {
            interact.informTimeout();
        });
    };

    Alice.only(() => {
        const wager = declassify(interact.wager);
        const deadline = declassify(interact.deadline);
    });
    Alice.publish(wager, deadline)
        .pay(wager);
    commit();

    Bob.only(() => {
        interact.acceptWager(wager);
    });
    Bob.pay(wager)
        .timeout(relativeTime(deadline), () => closeTo(Alice, informTimeout));

    var outcome = NO_ONE;
    invariant(balance() == 2 * wager && isOutcome(outcome));
    while (outcome == NO_ONE) {
        commit();

        Alice.only(() => {
            const _handAlice = interact.getHand();
            const [_commitAlice, _saltAlice] = makeCommitment(interact, _handAlice);
            const commitAlice = declassify(_commitAlice);
        });
        Alice.publish(commitAlice)
            .timeout(relativeTime(deadline), () => closeTo(Bob, informTimeout));
        commit();

        unknowable(Bob, Alice(_handAlice, _saltAlice));
        Bob.only(() => {
            const handBob = declassify(interact.getHand());
        });
        Bob.publish(handBob)
            .timeout(relativeTime(deadline), () => closeTo(Alice, informTimeout));
        commit();

        Alice.only(() => {
            const saltAlice = declassify(_saltAlice);
            const handAlice = declassify(_handAlice);
        });
        Alice.publish(saltAlice, handAlice)
            .timeout(relativeTime(deadline), () => closeTo(Bob, informTimeout));
        checkCommitment(commitAlice, saltAlice, handAlice);

        outcome = winner(handAlice, handBob, someAnswerArr);
        continue;
    }

    assert(outcome == A_WINS || outcome == B_WINS);
    transfer(2 * wager).to(outcome == A_WINS ? Alice : Bob);
    commit();

    each([Alice, Bob], () => {
        interact.seeOutcome(outcome);
    });
});