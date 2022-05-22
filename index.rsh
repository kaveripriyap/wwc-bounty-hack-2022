'reach 0.1';
'use strict';

const [isColor, VIOLET, INDIGO, BLUE, GREEN, YELLOW, ORANGE, RED] = makeEnum(7);
const [isOutcome, A_WINS, B_WINS, NO_ONE, TIMEOUT] = makeEnum(4);

const winner = (playA, playB, answerArr) => {
  const aIsCorrect = answerArr.any(x => x == playA);
  const bIsCorrect = answerArr.any(x => x == playB);
  if (aIsCorrect && !bIsCorrect) return A_WINS;
  else if (bIsCorrect && !aIsCorrect) return B_WINS;
  else return NO_ONE;
};

const someAnswerArr = array(UInt, [GREEN, YELLOW]);
assert(winner(VIOLET, INDIGO, someAnswerArr) == NO_ONE);
assert(winner(GREEN, YELLOW, someAnswerArr) == NO_ONE);
assert(winner(VIOLET, GREEN, someAnswerArr) == B_WINS);
assert(winner(YELLOW, INDIGO, someAnswerArr) == A_WINS);

forall(UInt, playA =>
  forall(UInt, playB =>
    assert(isOutcome(winner(playA, playB, someAnswerArr)))));

const Player = {
  ...hasRandom,
  getHand: Fun([], UInt),
  seeOutcome: Fun([UInt], Null),
};

export const main =
  Reach.App(
    {},
    [Participant('Alice',
      {
        ...Player,
        wager: UInt,
        deadline: UInt,
      }),
    Participant('Bob',
      {
        ...Player,
        acceptWager: Fun([UInt], Null)
      }),
    ],
    (Alice, Bob) => {
      const seeOutcome = (which) => () => {
        each([Alice, Bob], () =>
          interact.seeOutcome(which));
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
        .timeout(relativeTime(deadline), () => closeTo(Alice, seeOutcome(TIMEOUT)));

      var outcome = NO_ONE;
      invariant(balance() == 2 * wager);
      while (outcome == NO_ONE) {
        commit();

        Alice.only(() => {
          const _handAlice = interact.getHand();
          const [_commitAlice, _saltAlice] = makeCommitment(interact, _handAlice);
          const commitAlice = declassify(_commitAlice);
        });
        Alice.publish(commitAlice)
          .timeout(relativeTime(deadline), () => closeTo(Bob, seeOutcome(TIMEOUT)));
        commit();

        unknowable(Bob, Alice(_handAlice, _saltAlice));
        Bob.only(() => {
          const handBob = declassify(interact.getHand());
        });
        Bob.publish(handBob)
          .timeout(relativeTime(deadline), () => closeTo(Alice, seeOutcome(TIMEOUT)));
        commit();

        Alice.only(() => {
          const saltAlice = declassify(_saltAlice);
          const handAlice = declassify(_handAlice);
        });
        Alice.publish(saltAlice, handAlice)
          .timeout(relativeTime(deadline), () => closeTo(Bob, seeOutcome(TIMEOUT)));
        checkCommitment(commitAlice, saltAlice, handAlice);

        outcome = winner(handAlice, handBob, someAnswerArr);
        continue;
      }

      const winwho = outcome == A_WINS ? Alice : Bob;
      transfer(balance()).to(winwho);
      commit();
      seeOutcome(outcome)();
    });