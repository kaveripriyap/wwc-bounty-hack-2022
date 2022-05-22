'reach 0.1';
'use strict';

const [isColor, VIOLET, INDIGO, BLUE, GREEN, YELLOW, ORANGE, RED] = makeEnum(7);
const [isOutcomeA, A_WINS, B_WINS, LOSS, TIMEOUT] = makeEnum(4);

const Common = {
  seeOutcome: Fun([UInt], Null),
}

const GameM = {
  ...hasRandom,
  ...Common,
  getQuestion: Fun([], Array(UInt, 7)),
  wager: UInt,
  deadline: UInt,
}

const Player = {
  ...Common,
  getHand: Fun([Array(UInt, 7)], UInt),
  checkAnswer: Fun([UInt, Array(UInt, 7)], Bool),
  acceptWager: Fun([UInt], Null),
};

export const main =
  Reach.App(
    {},
    [Participant('GameMain', GameM),
    Participant('Alice', Player),
    Participant('Bob', Player),
    ],
    (GameMain, Alice, Bob) => {
      const seeOutcome = (which) => () => {
        each([GameMain, Alice, Bob], () =>
          interact.seeOutcome(which));
      };

      GameMain.only(() => {
        const wager = declassify(interact.wager);
        const deadline = declassify(interact.deadline);
        const question = declassify(interact.getQuestion());
      });
      GameMain.publish(wager, deadline, question);
      commit();

      Alice.only(() => {
        interact.acceptWager(wager);
      });
      Alice.pay(wager)
        .timeout(relativeTime(deadline), () => closeTo(GameMain, seeOutcome(TIMEOUT)));
      commit();

      Bob.only(() => {
        interact.acceptWager(wager);
      });
      Bob.pay(wager)
        .timeout(relativeTime(deadline), () => closeTo(GameMain, seeOutcome(TIMEOUT)));

      var outcome = LOSS;
      invariant(balance() == 2 * wager);
      while (outcome == LOSS) {
        commit();

        Alice.only(() => {
          const handAlice = declassify(interact.getHand(question));
          const isCorrectAlice = declassify(interact.checkAnswer(handAlice, question));
          const outc = isCorrectAlice ? A_WINS : LOSS;
        });

        Bob.only(() => {
          const handBob = declassify(interact.getHand(question));
          const isCorrectBob = declassify(interact.checkAnswer(handBob, question));
          const outc = isCorrectBob ? B_WINS : LOSS;
        });

        race(Alice, Bob).publish(outc);
        outcome = outc;
        continue;
      }

      const winwho = outcome == A_WINS ? Alice : Bob;
      transfer(balance()).to(winwho);
      commit();
      seeOutcome(outcome)();
    });