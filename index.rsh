'reach 0.1';
'use strict';

const [isColor, VIOLET, INDIGO, BLUE, GREEN, YELLOW, ORANGE, RED] = makeEnum(7);
const [isOutcome, B_WINS, B_LOSES, TIMEOUT] = makeEnum(3);

const winner = (play, question) => {
  const isCorrect = question[play] != play;
  if (isCorrect) return B_WINS;
  else return B_LOSES;
};

const someAnswerArr = array(UInt, [VIOLET, INDIGO, BLUE, YELLOW, GREEN, ORANGE, RED]);
assert(winner(GREEN, someAnswerArr) == B_WINS);
assert(winner(INDIGO, someAnswerArr) == B_LOSES);

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
    Participant('Bob', Player),
    ],
    (GameMain, Bob) => {
      const seeOutcome = (which) => () => {
        each([GameMain, Bob], () =>
          interact.seeOutcome(which));
      };

      GameMain.only(() => {
        const wager = declassify(interact.wager);
        const deadline = declassify(interact.deadline);
        const question = declassify(interact.getQuestion());
      });
      GameMain.publish(wager, deadline, question);
      commit();

      Bob.only(() => {
        interact.acceptWager(wager);
      });
      Bob.pay(wager)
        .timeout(relativeTime(deadline), () => closeTo(GameMain, seeOutcome(TIMEOUT)));

      var outcome = B_LOSES;
      invariant(balance() == wager);
      while (outcome == B_LOSES) {
        commit();

        Bob.only(() => {
          const handBob = declassify(interact.getHand(question));
          const isCorrect = declassify(interact.checkAnswer(handBob, question));
        });
        Bob.publish(handBob, isCorrect)
          .timeout(relativeTime(deadline), () => closeTo(GameMain, seeOutcome(TIMEOUT)));

        outcome = isCorrect ? B_WINS : B_LOSES;
        continue;
      }

      const winwho = outcome == B_WINS ? Bob : GameMain;
      transfer(balance()).to(winwho);
      commit();
      seeOutcome(outcome)();
    });