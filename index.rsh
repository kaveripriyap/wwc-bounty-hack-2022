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
  showOutcome: Fun([UInt], Null),
};

export const main =
  Reach.App(
    {},
    [Participant('Alice',
      {
        ...Player,
        getParams: Fun([], Object({
          wager: UInt,
          deadline: UInt
        }))
      }),
    Participant('Bob',
      {
        ...Player,
        confirmWager: Fun([UInt], Null)
      }),
    ],
    (Alice, Bob) => {
      const showOutcome = (which) => () => {
        each([Alice, Bob], () =>
          interact.showOutcome(which));
      };

      Alice.only(() => {
        const { wager, deadline } =
          declassify(interact.getParams());
        const handAlice = declassify(interact.getHand());
      });
      Alice.publish(handAlice, wager, deadline)
        .pay(wager);
      commit();

      Bob.only(() => {
        const handBob = declassify(interact.getHand());
        interact.confirmWager(wager);
      });
      Bob.publish(handBob)
        .pay(wager)
        .timeout(relativeTime(deadline), () => closeTo(Alice, showOutcome(TIMEOUT)));
      commit();

      // This wait is so that Bob doesn't have an advantage. Otherwise he'd be
      // able to include the last publish and the next one at the same time;
      // but with this protocol, now Alice can ensure that the race doesn't
      // start until she has enough time to know that Bob has accepted.
      wait(relativeTime(deadline));
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
      showOutcome(outcome)();
    });