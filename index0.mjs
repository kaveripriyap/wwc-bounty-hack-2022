import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);

const numOfBuyers = 2;
const HAND = ['VIOLET', 'INDIGO', 'BLUE', 'GREEN', 'YELLOW', 'ORANGE', 'RED'];

const accFunder = await stdlib.newTestAccount(startingBalance);
const accBuyerArray = await Promise.all(
    Array.from({ length: numOfBuyers }, () =>
        stdlib.newTestAccount(startingBalance)
    )
);

const ctcFunder = accFunder.contract(backend);
const ctcInfo = ctcFunder.getInfo();

const funderParams = {
    wager: stdlib.parseCurrency(5),
    deadline: 2,
    solutions: [0, 6],
};

await Promise.all([
    backend.Funder(ctcFunder, {
        showOutcome: (outcome) => console.log(`Funder saw ${stdlib.formatAddress(outcome[0])} and ${stdlib.formatAddress(outcome[1])} won.`),
        getParams: () => funderParams,
    }),
].concat(
    accBuyerArray.map((accBuyer, i) => {
        const ctcBuyer = accBuyer.contract(backend, ctcInfo);
        return backend.Buyer(ctcBuyer, {
            showOutcome: (outcome) => {
                console.log(`Buyer ${i} saw they ${stdlib.addressEq(outcome[0], accBuyer) || stdlib.addressEq(outcome[1], accBuyer) ? 'won' : 'lost'}.`);
            },
            getAnswers: () => {
                const ans1 = Math.floor(Math.random() * 7);
                const ans2 = Math.floor(Math.random() * 7);
                return [ans1, ans2];
            },
            showAnswers: (addr, answers) => {
                if (stdlib.addressEq(addr, accBuyer)) {
                    console.log(`Buyer ${i} played ${HAND[answers[0]]} and ${HAND[answers[1]]}`);
                }
            }
        });
    })
));