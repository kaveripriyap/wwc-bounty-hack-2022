'reach 0.1';
'use strict';

const [isColor, VIOLET, INDIGO, BLUE, GREEN, YELLOW, ORANGE, RED] = makeEnum(7);
const [isOutcome, CORRECT, WRONG, TIMEOUT] = makeEnum(3);

const isWinner = (play, answerArr) => {
  if (answerArr.any(x => x == play)) return CORRECT;
  else return WRONG;
};

const someAnswerArr = array(UInt, [GREEN, YELLOW]);
assert(isWinner(VIOLET, someAnswerArr) == WRONG);
assert(isWinner(GREEN, someAnswerArr) == CORRECT);

forall(UInt, play =>
  assert(isOutcome(isWinner(play, someAnswerArr))));

const Common = {
  seeOutcome: Fun([Address], Null),
}

const GameMaster = {
  ...hasRandom,
  ...Common,
  getQuestion: Fun([], Array(UInt, 7)),
  checkAnswer: Fun([UInt], Bool),
  wager: UInt,
  deadline: UInt,
}

const Player = {
  ...Common,
  getHand: Fun([Array(UInt, 7)], UInt),
  acceptWager: Fun([UInt], Null),
};

export const main =
  Reach.App(
    {},
    [
      Participant('GM', { ...GameMaster }),
      ParticipantClass('Kaavi',
        {
          ...Player,
          acceptWager: Fun([UInt], Null)
        }),
    ],
    (GM, Kaavi) => {
      const seeOutcome = (which) => () => {
        each([GM, Kaavi], () =>
          interact.seeOutcome(which));
      };

      GM.publish();
      commit();

      GM.only(() => {
        const wager = declassify(interact.wager);
        const deadline = declassify(interact.deadline);
        const question = declassify(interact.getQuestion());
      });
      GM.publish(wager, deadline, question);

      Kaavi.only(() => {
        interact.acceptWager(wager);
      });
      commit();
      Kaavi.publish();

      const [timeRemaining, keepGoing] = makeDeadline(deadline);
      const [answerTime, keepAccepting] = makeDeadline(2 * deadline);

      const [ winner, numOfPlayers ] =
        parallelReduce([ GM, 0])
          .invariant(balance() == numOfPlayers * wager)
          .while(keepGoing())
          .case(Kaavi,
            (() => ({
              when: declassify(interact.getHand(question)) >= 0 && declassify(interact.getHand(question)) < 7,
              msg: declassify(interact.getHand(question)),
            })),
            ((_) => wager),
            ((hand) => {
              const kaavi = this;

              GM.only(() => {
                const isCorrect = declassify(interact.checkAnswer(hand));
              });
              commit();
              GM.publish(isCorrect);
              const outcome = isCorrect ? kaavi : winner;
              return [outcome, numOfPlayers + 1];
            }))
          .timeout(timeRemaining(), () => {
            Anybody.publish();
            return [GM, numOfPlayers];
          });
      commit();

      Kaavi.only(() => {
        const itsame = winner == this;
      });
      Kaavi.publish().when(itsame)
        .timeout(relativeTime(deadline), () => closeTo(GM, () => { }));

      transfer(balance()).to(winner);
      commit();
      seeOutcome(winner)();
    });