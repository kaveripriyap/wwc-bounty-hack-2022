'reach 0.1';
'use strict';

const CommonInterface = {
    // Show the address of winner
    showWinner: Fun([Bool, Address, UInt], Null),
};

const FunderInterface = {
    ...CommonInterface,
    getParams: Fun([], Object({
        wager: UInt,
        question: Array(UInt, 7),
        solutions: Array(UInt, 2),
        deadline: UInt,  // relative deadline
    })),
};

const BuyerInterface = {
    ...CommonInterface,
    getAnswers: Fun([], Array(UInt, 2)),
    showAnswers: Fun([Address, Array(UInt, 2)], Null),
};

export const main = 
  Reach.App(() => {
    const Funder = Participant('Funder', FunderInterface);
    const Buyer = ParticipantClass('Buyer', BuyerInterface);
    init();

    Funder.publish();
    commit();
    // Have the funder publish the solutions and deadline
    Funder.only(() => {
        const { wager, question, solutions, deadline } =
            declassify(interact.getParams());
    });
    Funder.publish(wager, question, solutions, deadline)
        .pay(wager);

    const [bidTimeout, keepBidding] =
        makeDeadline(deadline);

    const bidsM = new Map(UInt);
    const getBid = (who) =>
        fromMaybe(bidsM[who], (() => 0), (x => x));

    // Helper to display results to everyone
    const showOutcome = (who) =>
        each([Funder, Buyer], () => {
            interact.showOutcome(who);
        });

    // Until timeout, allow buyers to submit answers
    const [winner, winningBid] =
        parallelReduce([Funder, 0])
            .invariant(balance() == wager + bidsM.sum())
            .invariant(balance() == wager + Map.sum(bidsM))
            .while(keepBidding())
            .case(
                Buyer, () => ({
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
            .timeRemaining(bidTimeout());

    // Whoever submits correctly wins and receives balance
    commit();

    Bidder.only(() => {
        const itsame = winner == this;
    });
    Bidder.publish().when(itsame)
        .timeout(relativeTime(deadline), () => closeTo(Sponsor, () => { }));
    transfer(wager).to(winner);
    transfer(balance()).to(Sponsor);
    commit();

    each([Funder, Buyer], () => {
        interact.showWinner(true, winner, winningBid);
    });
});