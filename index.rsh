'reach 0.1';
'use strict';

const CommonInterface = {
    // Show the address of winner
    showOutcome: Fun([Array(Address, 2)], Null),
};

const FunderInterface = {
    ...CommonInterface,
    getParams: Fun([], Object({
        deadline: UInt,  // relative deadline
        solutions: Array(UInt, 2),
        wager: UInt,
    })),
};

const BuyerInterface = {
    ...CommonInterface,
    getAnswers: Fun([], Array(UInt, 2)),
    showAnswers: Fun([Address, Array(UInt, 2)], Null),
};

export const main = Reach.App(
    {},
    [
        Participant('Funder', FunderInterface),
        ParticipantClass('Buyer', BuyerInterface),
    ],
    (Funder, Buyer) => {

        // Helper to display results to everyone
        const showOutcome = (who) =>
            each([Funder, Buyer], () => {
                interact.showOutcome(who);
            });

        // Have the funder publish the solutions and deadline
        Funder.only(() => {
            const { wager, solutions, deadline } =
                declassify(interact.getParams());
        });
        Funder.publish(wager, solutions, deadline);

        // Until timeout, allow buyers to submit answers
        const [keepGoing, winner1, winner2, enteredPlayers] =
            parallelReduce([true, Funder, Funder, 0])
                .invariant(balance() == enteredPlayers * wager)
                .while(keepGoing)
                .case(
                    Buyer,
                    () => ({
                        when: declassify(interact.getAnswers()).size() > 0,
                    }),
                    (_) => wager,
                    (_) => {
                        const buyer = this;
                        Buyer.only(() => {
                            const answers = declassify(interact.getAnswers());
                            interact.showAnswers(buyer, answers);
                            //const newWinner1 = answers.any(x => x == solutions[0]) ? buyer : winner1;
                            //const newWinner2 = answers.any(x => x == solutions[1]) ? buyer : winner2;
                            //const keepGoingNew = winner1 == Funder || winner2 == Funder;
                        });
                        return [true, buyer, Funder, enteredPlayers + 1];
                    }
                )
                .timeout(relativeTime(deadline), () => {
                    Anybody.publish();
                    return [false, winner1, winner2, enteredPlayers];
                });

        // Whoever submits correctly wins and receives balance
        const prize = balance() - 10;
        transfer(prize).to(winner1);
        transfer(10).to(winner2);
        commit();
        showOutcome(array(Address, [winner1, winner2]));
    });