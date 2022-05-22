'reach 0.1';
'use strict';

const [isColor, VIOLET, INDIGO, BLUE, GREEN, YELLOW, ORANGE, RED] = makeEnum(7);
const [isOutcome, A_WINS, B_WINS, NO_ONE, TIMEOUT] = makeEnum(4);

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
      commit();

      // This wait is so that Bob doesn't have an advantage. Otherwise he'd be
      // able to include the last publish and the next one at the same time;
      // but with this protocol, now Alice can ensure that the race doesn't
      // start until she has enough time to know that Bob has accepted.
      Alice.only(() => {
        const outcome = winner(handAlice, handBob, someAnswerArr);
      });
      Bob.only(() => {
        const outcome = winner(handAlice, handBob, someAnswerArr);
      });


      race(Alice, Bob).publish(outcome);
      const winwho = outcome == A_WINS ? Alice : Bob;
      transfer(balance()).to(winwho);
      commit();
      seeOutcome(outcome)();
    });