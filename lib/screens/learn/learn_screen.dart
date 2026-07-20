import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';

// ─── DATA ──────────────────────────────────────────────────────────────────

class FinanceLesson {
  final String id;
  final String title;
  final String hook;
  final String level;
  final String explanation;
  final String realLife;
  final String remember;
  final String ledgrrSees;

  const FinanceLesson({
    required this.id,
    required this.title,
    required this.hook,
    required this.level,
    required this.explanation,
    required this.realLife,
    required this.remember,
    required this.ledgrrSees,
  });
}

const List<FinanceLesson> _allLessons = [
  // ── FOUNDATION ──────────────────────────────────────────────────────────
  FinanceLesson(
    id: 'f1',
    level: 'Foundation',
    title: 'What is a budget and why yours is probably wrong',
    hook: 'A budget is not a punishment. It is a plan.',
    explanation:
        'A budget is simply deciding in advance where your money goes instead of wondering after where it went. Most students either skip budgeting entirely or set one so strict they break it in three days and give up.\n\nThe right budget has three parts — what comes in, what must go out, and what you choose to spend. That last part is where most people go wrong. They forget that fun, food with friends, and random impulse buys are real and predictable. A budget that does not include them is a budget that will fail.\n\nThe golden rule: your total spending must be less than your total income. That gap — however small — is your power.',
    realLife:
        'Arjun gets ₹8,000 allowance every month. He budgets ₹3,000 for rent, ₹1,500 for food, ₹500 for transport. That leaves ₹3,000. He spends ₹2,800 on random things and wonders why he is broke by the 25th. The fix is simple — he needs to decide what that ₹3,000 is for before he spends it, not after.',
    remember:
        'A budget you cannot follow is not a budget. It is a wish list.',
    ledgrrSees:
        'Your monthly income and spending limit in LEDGRR is your budget. Check if you are staying within it under Statistics.',
  ),
  FinanceLesson(
    id: 'f2',
    level: 'Foundation',
    title: 'Income vs expense — the only equation that matters',
    hook: 'If income is bigger, you win. If expense is bigger, you lose. That is it.',
    explanation:
        'Every financial decision in your life comes down to one equation: Income minus Expense equals Savings. If that number is positive, you are building something. If it is negative, you are falling behind.\n\nIncome is every rupee that comes in — allowance, stipend, part-time work, gifts, freelance. Expense is every rupee that goes out — rent, food, transport, subscriptions, everything.\n\nThe goal is not to earn more or spend less — the goal is to make the gap between them bigger over time. You can do that by earning more, spending less, or both.',
    realLife:
        'Priya earns ₹12,000 from her internship stipend. She spends ₹11,400 across rent, food, transport, and shopping. Her savings that month is ₹600. That is not nothing — but it means one unexpected expense wipes her out. Understanding this equation is the first step to changing it.',
    remember:
        'You do not need to earn a lot to save. You need to spend less than you earn. Always.',
    ledgrrSees:
        'Your True Balance in LEDGRR is this equation applied to your entire financial history — not just this month.',
  ),
  FinanceLesson(
    id: 'f3',
    level: 'Foundation',
    title: 'What True Balance actually means',
    hook: 'Your bank balance lies. Your True Balance does not.',
    explanation:
        'Your bank balance shows what is in your account right now. But it does not know about the ₹500 you owe your roommate, the ₹1,200 EMI coming next week, or the ₹800 you already mentally spent on that concert ticket.\n\nTrue Balance is what is actually yours after everything is accounted for. It is the number that tells you the real answer to "can I afford this?"\n\nMost people spend based on their bank balance and get surprised when they run out. People who understand True Balance spend based on reality.',
    realLife:
        'Karthik sees ₹4,500 in his account and thinks he can buy those sneakers. But he forgot — ₹2,000 rent is due in 4 days, he owes ₹600 to a friend, and his Spotify and Netflix auto-deduct ₹400 this week. His True Balance is ₹1,500. The sneakers can wait.',
    remember:
        'Never spend from your bank balance. Spend from your True Balance.',
    ledgrrSees:
        'The True Balance card on your LEDGRR home screen is exactly this — every rupee in minus every rupee out, from the beginning.',
  ),
  FinanceLesson(
    id: 'f4',
    level: 'Foundation',
    title: 'Why saving ₹100 today beats saving ₹1000 next year',
    hook: 'Time is the one thing money cannot buy back.',
    explanation:
        'This sounds like motivational content but it is actually mathematics. The earlier you save, the longer your money has to grow. Even tiny amounts started early beat large amounts started late — because of something called compound interest.\n\nCompound interest means your savings earn interest, and then that interest earns interest on top of itself. The longer this cycle runs, the more powerful it becomes.\n\nMost students say "I will start saving when I get a real job." By then, they have lost years of growth that cannot be recovered.',
    realLife:
        'Divya saves ₹500 a month from age 20. Her friend Meera saves ₹2,000 a month but starts at 30. By 40, Divya has more money — despite saving four times less per month — because she started 10 years earlier.',
    remember:
        'Start saving something — anything — today. The amount matters less than the habit.',
    ledgrrSees:
        'Track your monthly savings in LEDGRR under Statistics. Even ₹200 saved consistently shows up as a pattern over time.',
  ),
  FinanceLesson(
    id: 'f5',
    level: 'Foundation',
    title: 'UPI, cash, cards — which one makes you spend more',
    hook: 'The easier money is to spend, the more you spend.',
    explanation:
        'This is not an opinion — it is backed by research. When you pay with cash, you physically hand over something. That small moment of friction makes you think twice. When you tap UPI or swipe a card, it feels like nothing left your hands.\n\nUPI and cards are not bad — they are convenient and safe. But convenience has a cost. People who track their UPI spending are often shocked by how much they spent on things they barely remember.\n\nThe fix is not to stop using UPI. The fix is to log every transaction. The act of recording it creates the friction that cash used to create.',
    realLife:
        'Rahul withdrew ₹2,000 cash at the start of the month. He was very careful with every note. The next month he used only UPI and spent ₹3,800 — almost double — without noticing. Same income. Same lifestyle. Different payment method.',
    remember:
        'Log every transaction the moment it happens. That is your friction.',
    ledgrrSees:
        'Every time you add a transaction in LEDGRR you are creating that friction. It is not a chore — it is the habit that changes your relationship with money.',
  ),
  FinanceLesson(
    id: 'f6',
    level: 'Foundation',
    title: 'What your bank statement is trying to tell you',
    hook: 'Your bank statement is an honest record of your priorities.',
    explanation:
        'Most people open their bank statement only when something goes wrong. But your statement is actually the most honest document about your life — it shows exactly what you valued enough to spend money on.\n\nLook at last month\'s statement. What do you see? Food delivery at 2am, subscriptions you forgot about, multiple small UPI transfers that add up to a big number, one or two large purchases you remember. That is your financial portrait.\n\nReading your statement monthly is not about guilt. It is about awareness. You cannot change what you cannot see.',
    realLife:
        'Sneha downloaded her bank statement for the first time in six months. She found three subscriptions she forgot to cancel after free trials — ₹1,400 total, gone every month for six months. That is ₹8,400 she could have had. Ghost money.',
    remember:
        'Read your bank statement once a month. Treat it like a report card you actually learn from.',
    ledgrrSees:
        'Your LEDGRR transaction history is a cleaner version of your bank statement — categorized, searchable, and honest.',
  ),
  FinanceLesson(
    id: 'f7',
    level: 'Foundation',
    title: 'Needs, wants, and "I deserve this"',
    hook: '"I deserve this" is the most expensive phrase in the English language.',
    explanation:
        'Needs are things without which you cannot function — rent, food, medicine, transport to college or work. Wants are things that improve your life but you can survive without — eating out, new clothes, entertainment.\n\nThen there is the third category that nobody talks about: "I deserve this." This is a want disguised as a need. It is the expensive coffee after a hard exam, the new phone because you have been stressed, the shopping trip because you had a bad week.\n\nDeserving things is real. The problem is when it becomes a financial habit — when every difficult moment justifies a purchase. That pattern is expensive and it feels justified every single time.',
    realLife:
        'Aditya had a terrible exam week. He ordered food delivery three times, bought a hoodie he had been eyeing, and topped up his gaming account. Total: ₹2,100. He felt better for two days. Then he felt worse because he was broke. The stress did not go away. The money did.',
    remember:
        'You deserve good things. Make sure you can actually afford them first.',
    ledgrrSees:
        'Check your spending spikes in LEDGRR Statistics. They often align with stressful weeks. Awareness is the first step.',
  ),

  // ── CLARITY ─────────────────────────────────────────────────────────────
  FinanceLesson(
    id: 'c1',
    level: 'Clarity',
    title: 'How subscriptions quietly eat your money',
    hook: 'You did not decide to spend ₹1,500 this month. But you did.',
    explanation:
        'Subscriptions are the cleverest financial trap ever invented — not because they are evil, but because they are invisible. You sign up once and forget. The money leaves every month without you making a decision.\n\nNetflix, Spotify, Prime, Hotstar, YouTube Premium, iCloud storage, LinkedIn Premium, app subscriptions, gym memberships, meal kit services — individually each one seems small. Together they can easily cross ₹2,000 to ₹3,000 a month.\n\nThe rule is simple: if you have not used it in 30 days, cancel it. You can always re-subscribe. You cannot un-spend the money you already lost.',
    realLife:
        'Vikram listed all his subscriptions one evening. He found 8 of them. Three he had completely forgotten about. Two he used maybe once a month. Total monthly drain: ₹2,340. He cancelled five of them and saved ₹1,600 a month — without changing his lifestyle at all.',
    remember:
        'Audit your subscriptions every 3 months. Cancel anything you have not used since you last checked.',
    ledgrrSees:
        'Your Ghost Money Detector in LEDGRR scans for exactly this — recurring charges that silently drain your account every month.',
  ),
  FinanceLesson(
    id: 'c2',
    level: 'Clarity',
    title: 'What an FD is and when it makes sense',
    hook: 'Your savings account is losing money. Slowly. Quietly.',
    explanation:
        'A Fixed Deposit is when you put money in a bank for a fixed period of time — say 6 months or 1 year — and the bank pays you a higher interest rate than a regular savings account.\n\nSavings accounts in India typically pay 2.5% to 3.5% interest. FDs pay 5.5% to 7.5% depending on the bank and tenure. Inflation in India runs at roughly 5% to 6%. This means money sitting in a savings account is actually losing value in real terms.\n\nFDs are not glamorous. They are not going to make you rich. But they are safe, guaranteed, and better than nothing for money you do not need immediately.',
    realLife:
        'Ananya had ₹15,000 sitting in her savings account for 8 months — her emergency fund. Her bank paid 3% interest. She moved it to an FD at 6.5% for 6 months and earned ₹487 extra — enough for a good dinner out — just by moving the money.',
    remember:
        'Any money you will not touch for 6 months or more belongs in an FD, not a savings account.',
    ledgrrSees:
        'When your True Balance stays consistently positive in LEDGRR, that surplus is what belongs in an FD.',
  ),
  FinanceLesson(
    id: 'c3',
    level: 'Clarity',
    title: 'SIPs — what they are and why ₹500 a month matters',
    hook: 'You do not need money to invest. You need a habit.',
    explanation:
        'A Systematic Investment Plan or SIP is when you invest a fixed amount into a mutual fund every month — automatically. The minimum is often ₹500.\n\nMutual funds pool money from many investors and invest in stocks, bonds, or both. A fund manager decides where the money goes. Over long periods — 10, 15, 20 years — well-chosen mutual funds have historically returned 10% to 15% annually, far more than FDs.\n\nThe magic of SIPs is two things: you do not need a lump sum to start, and you do not need to time the market. Every month you buy some units. When markets are down you buy more units for the same money. Over time this averages out and grows.\n\nFor a student, even ₹500 a month started at 20 is a genuinely powerful decision.',
    realLife:
        'Rohan started a ₹500/month SIP at 21 in an index fund returning 12% annually. By 31 he had invested ₹60,000 total. His actual value: over ₹1,00,000. By 40 — still just ₹500/month — his corpus would be over ₹5,00,000. He never increased the amount. Time did the work.',
    remember:
        'Start a SIP before you feel ready. ₹500 today is worth more than ₹5,000 five years from now.',
    ledgrrSees:
        'Log your SIP as a monthly expense in LEDGRR under "Savings" category so you track it as a non-negotiable.',
  ),
  FinanceLesson(
    id: 'c4',
    level: 'Clarity',
    title: 'Credit cards — the trap and the tool',
    hook: 'A credit card is free money until it is not.',
    explanation:
        'A credit card lets you spend money you do not have yet, with the promise to pay it back. If you pay the full amount every month before the due date — you pay zero interest and often earn rewards. If you pay only the minimum — you pay 36% to 42% annual interest on the remaining balance. That is not a typo.\n\nCredit cards are a powerful tool when used correctly: pay in full every month, use the rewards, build your credit score. They are a catastrophic trap when used as extra money — spending beyond your income and rolling over the balance.\n\nFor students — if you cannot trust yourself to pay the full amount every month, do not get one yet. A debit card does the same things without the risk.',
    realLife:
        'Meera got her first credit card and spent ₹8,000 on clothes and gadgets. She paid only the minimum of ₹800. The remaining ₹7,200 attracted 3% monthly interest. In six months of paying minimums she had paid ₹4,800 in payments but still owed ₹6,100. The clothes were long forgotten.',
    remember:
        'A credit card is only free if you pay the full amount every single month. Not most months. Every month.',
    ledgrrSees:
        'Track your credit card spending as a category in LEDGRR so you always know what bill is coming.',
  ),
  FinanceLesson(
    id: 'c5',
    level: 'Clarity',
    title: 'Emergency fund — what it is and how much you need',
    hook: 'An emergency fund is not savings. It is insurance.',
    explanation:
        'An emergency fund is money set aside only for genuine emergencies — medical expenses, sudden loss of income, urgent travel, essential repairs. It is not for sales, opportunities, or things you want but did not plan for.\n\nThe standard advice is 3 to 6 months of expenses. For a student that might mean ₹15,000 to ₹30,000. It should sit in a liquid account — savings account or liquid mutual fund — where you can access it within 24 hours.\n\nWithout an emergency fund, any unexpected expense forces you to borrow — from family, friends, or worse, at high interest. The stress of not having a financial cushion is one of the most underrated sources of anxiety for young people.',
    realLife:
        'Siddharth had no emergency fund. His laptop died three weeks before his project submission. He had to borrow ₹12,000 from four different people, felt terrible about it, and spent two months paying them back — while still living on his regular budget. A ₹12,000 emergency fund sitting in his account would have made it a non-event.',
    remember:
        'Build your emergency fund before you invest in anything. It is the foundation everything else sits on.',
    ledgrrSees:
        'Keep your emergency fund as a separate Event Wallet goal in LEDGRR so you always see how close you are to fully funded.',
  ),
  FinanceLesson(
    id: 'c6',
    level: 'Clarity',
    title: 'How inflation affects your pocket money',
    hook: '₹100 today will not buy what ₹100 bought last year.',
    explanation:
        'Inflation is the rate at which prices rise over time. In India it typically runs at 5% to 7% per year. This means if you got ₹5,000 pocket money two years ago and still get ₹5,000 today, you are actually poorer — because the same money buys less.\n\nThis is why keeping money idle — in a piggy bank or in a zero-interest account — is not neutral. It is slowly losing value. This is also why salary growth matters, why investments matter, and why understanding inflation is not just for economists.\n\nFor students: your hostel food is more expensive than it was two years ago. Your auto fare has increased. That is inflation working against you in real time.',
    realLife:
        'Nisha\'s mess food cost ₹2,200 a month in her first year. By her third year it was ₹2,700 — a 23% increase over two years. Her parents still sent the same ₹8,000 allowance. Effectively she was receiving less money every year, even though the number looked the same.',
    remember:
        'Money that is not growing is shrinking. Inflation is always running in the background.',
    ledgrrSees:
        'Compare your monthly expense totals across months in LEDGRR Statistics. A gradual upward trend is often inflation, not lifestyle inflation.',
  ),
  FinanceLesson(
    id: 'c7',
    level: 'Clarity',
    title: 'Net worth — what it is and yours right now',
    hook: 'Net worth is not just for rich people. It is for everyone who wants to become one.',
    explanation:
        'Net worth is everything you own minus everything you owe. Assets minus liabilities. It is the single most honest number about your financial health.\n\nFor a student, assets might include: money in bank accounts, savings, investments, value of things you own. Liabilities might include: money owed to friends, any loans, credit card debt.\n\nMost students have a net worth close to zero or slightly negative — and that is okay. What matters is the direction. Is it going up or down? Even a small positive change every month is building something real.',
    realLife:
        'Arjun calculated his net worth for the first time. Assets: ₹4,200 in savings account, ₹6,000 in his SIP, laptop worth ₹25,000. Total: ₹35,200. Liabilities: ₹3,000 owed to a friend, ₹1,200 credit card bill. Net worth: ₹31,000. Not huge — but positive and growing.',
    remember:
        'Calculate your net worth every 3 months. The direction matters more than the number.',
    ledgrrSees:
        'Your True Balance in LEDGRR is the core of your net worth calculation. Add your savings and investments to get the full picture.',
  ),

  // ── MASTERY ─────────────────────────────────────────────────────────────
  FinanceLesson(
    id: 'm1',
    level: 'Mastery',
    title: 'Compound interest — the force you are ignoring',
    hook: 'Einstein called it the eighth wonder of the world. He was not exaggerating.',
    explanation:
        'Compound interest is interest on interest. When your money earns returns and those returns themselves earn returns, the growth becomes exponential over time — not linear.\n\nThe formula is simple: Amount = Principal × (1 + rate)^time. What this means in practice is that time is the most powerful variable. Doubling the time you invest does not double your returns — it multiplies them many times over.\n\nThe rule of 72 is a quick mental math trick: divide 72 by your annual interest rate to find how many years it takes to double your money. At 8% it takes 9 years. At 12% it takes 6 years. At 36% credit card interest — your debt doubles in 2 years.',
    realLife:
        'Two students invest ₹1,00,000 each. One invests at 12% and leaves it for 20 years: final value ₹9,64,629. The other waits 10 years before investing the same amount at the same rate for 20 years: final value ₹3,10,585. Same money. Same rate. The 10-year head start created a ₹6,54,044 difference.',
    remember:
        'Compound interest rewards patience more than it rewards intelligence. Start early, stay invested.',
    ledgrrSees:
        'Log your investments as income entries in LEDGRR and watch your True Balance compound story unfold over months.',
  ),
  FinanceLesson(
    id: 'm2',
    level: 'Mastery',
    title: 'Tax basics every fresher needs to know',
    hook: 'You will get taxed whether you understand it or not. Better to understand it.',
    explanation:
        'In India, income tax is calculated on your annual income using slabs. Under the new regime for FY 2024-25, income up to ₹3 lakh is tax-free. From ₹3 to ₹6 lakh, you pay 5%. From ₹6 to ₹9 lakh, you pay 10%, and so on.\n\nTDS means Tax Deducted at Source — your employer deducts tax before paying your salary. Form 16 is the document your employer gives you showing how much was deducted. ITR means Income Tax Return — the form you file every year to tell the government your income and claim refunds if too much tax was deducted.\n\nFor most fresh graduates earning under ₹7 lakh, the rebate under Section 87A means you pay zero tax. But you still need to file your ITR every year — it is legally required and builds your financial history.',
    realLife:
        'Priya got her first job at ₹4.5 lakh per year CTC. Her HR said ₹35,000 TDS would be deducted annually. She panicked. Then she learned that under the new tax regime with the ₹87A rebate her actual tax liability was zero. She filed her ITR, claimed a full refund of ₹35,000, and got it back in 3 weeks.',
    remember:
        'File your ITR every year even if you owe zero tax. It is your financial report card with the government.',
    ledgrrSees:
        'Use LEDGRR to track your monthly in-hand salary so you always know your actual annual income for ITR filing.',
  ),
  FinanceLesson(
    id: 'm3',
    level: 'Mastery',
    title: 'CTC vs in-hand — why your offer letter is misleading',
    hook: 'That ₹6 LPA offer letter is not ₹50,000 a month. Here is why.',
    explanation:
        'CTC means Cost to Company — the total amount the company spends on you. In-hand salary is what actually reaches your bank account. The difference can be 25% to 40%.\n\nWhat eats into your CTC: PF contribution (12% of basic from your side, which is a saving but not cash in hand), gratuity (paid only after 5 years), medical insurance (benefit but not cash), performance bonus (paid annually, not monthly), other allowances that come with conditions.\n\nA ₹6 LPA CTC typically means ₹38,000 to ₹42,000 in hand per month — not ₹50,000. Always ask for the in-hand breakup before accepting an offer.',
    realLife:
        'Karan accepted a ₹7.2 LPA offer expecting ₹60,000 a month. His first salary was ₹46,500. He had already told his parents he would send ₹15,000 home. He had mentally planned a lifestyle for ₹60,000. The first month was a financial shock that took three months to recover from.',
    remember:
        'Always ask "what is the monthly in-hand amount?" before signing any offer letter.',
    ledgrrSees:
        'Enter your actual in-hand salary as income in LEDGRR — not your CTC. That is the number that matters for your budget.',
  ),
  FinanceLesson(
    id: 'm4',
    level: 'Mastery',
    title: '₹2,000 SIP from age 20 — what it looks like at 40',
    hook: 'Numbers are more motivating than advice. Here are the numbers.',
    explanation:
        'If you invest ₹2,000 every month in an index fund returning 12% annually starting at age 20:\n\nAt 25: you have invested ₹1,20,000. Value: ₹1,63,000.\nAt 30: you have invested ₹2,40,000. Value: ₹4,80,000.\nAt 35: you have invested ₹3,60,000. Value: ₹11,20,000.\nAt 40: you have invested ₹4,80,000. Value: ₹26,40,000.\n\nYou invested ₹4.8 lakh over 20 years. Your corpus is ₹26.4 lakh. The extra ₹21.6 lakh came entirely from compound growth — you did nothing except not stop.\n\nIf you wait until 30 to start the same SIP: at 40 your corpus is only ₹9.2 lakh. The 10-year delay cost you ₹17 lakh.',
    realLife:
        'These are not hypothetical numbers. This is what index funds in India have historically delivered over 15-20 year periods. The Nifty 50 has returned approximately 12-13% CAGR over the last 25 years.',
    remember:
        'The best time to start a SIP was yesterday. The second best time is today.',
    ledgrrSees:
        'Set a monthly SIP as a recurring savings goal in your Event Wallet in LEDGRR so you treat it as a non-negotiable expense.',
  ),
  FinanceLesson(
    id: 'm5',
    level: 'Mastery',
    title: 'Health insurance — before you think you need it',
    hook: 'One hospital stay can wipe out everything you saved in a year.',
    explanation:
        'Health insurance pays for your medical expenses in exchange for a monthly or annual premium. In India, a basic individual health plan with ₹5 lakh coverage costs ₹6,000 to ₹10,000 per year for someone in their 20s — roughly ₹500 to ₹800 a month.\n\nWithout health insurance, one serious illness or accident can cost ₹1 lakh to ₹5 lakh or more. That wipes out savings, forces loans, and creates financial trauma that takes years to recover from.\n\nMost students are covered under their parents\' family floater plan. Check if you are. If you are not, or if you will be living in a different city than your parents, get your own plan immediately. The younger you are when you buy it, the lower your premium will be for life.',
    realLife:
        'Deepa, 22, had a kidney infection during her final year exams. Three days in a private hospital in Chennai: ₹78,000. She had no health insurance. She borrowed from three sources and spent her entire internship stipend for four months paying it back. A health plan would have cost her ₹7,000 for the entire year.',
    remember:
        'Health insurance is not optional. It is the first financial product every working young person needs.',
    ledgrrSees:
        'Log your health insurance premium as a yearly expense in LEDGRR under Health category so it never catches you off guard.',
  ),
  FinanceLesson(
    id: 'm6',
    level: 'Mastery',
    title: 'The psychology of money — why we spend emotionally',
    hook: 'Your brain was not built for modern money. That is not an excuse. It is a starting point.',
    explanation:
        'Humans evolved in an environment where resources were scarce and immediate. Our brains are wired to spend now and worry about tomorrow later. Modern marketing exploits this ruthlessly — sales, limited time offers, influencer endorsements, app notifications — all designed to trigger emotional spending before your rational brain catches up.\n\nKey biases that cost you money:\n\nPresent bias: you value ₹1,000 today more than ₹2,000 next year even though ₹2,000 is objectively better.\n\nAnchoring: when you see a product "marked down" from ₹2,000 to ₹1,200 you feel like you saved ₹800 — even if it was never worth ₹2,000.\n\nSocial spending: spending to match or impress people around you — often people you do not even like that much.\n\nUnderstanding these biases does not make you immune. But it gives you a one-second pause before clicking buy.',
    realLife:
        'Akash saw a sale on a gadget he had been wanting. "60% off, only 3 left in stock, ends in 2 hours." He bought it immediately for ₹3,600. Later he found the same gadget available at ₹3,200 with no urgency. The artificial scarcity made him spend faster and more than he needed to.',
    remember:
        'When you feel urgency to buy something, wait 24 hours. If you still want it the next day, buy it. Most times you will not.',
    ledgrrSees:
        'Review your LEDGRR transactions from last month. Circle everything bought on impulse. That number is your emotional spending tax.',
  ),
  FinanceLesson(
    id: 'm7',
    level: 'Mastery',
    title: 'How to read your finances like a CFO',
    hook: 'A CFO does not panic about money. They read the numbers and decide.',
    explanation:
        'A Chief Financial Officer looks at three things: what came in, what went out, and what is left. Then they ask three questions: is this sustainable, where are the leaks, and what should we do differently next month.\n\nYou can do the same thing with your personal finances in 10 minutes a month.\n\nStep 1: Total your income for the month.\nStep 2: Total your expenses by category.\nStep 3: Find your top 3 expense categories.\nStep 4: Ask — is each one worth what I spent on it?\nStep 5: Decide one thing to change next month.\n\nThat is it. No complicated spreadsheet. No financial degree required. Just honest numbers and one decision.',
    realLife:
        'Shruti spent 10 minutes reviewing her LEDGRR statistics at the end of the month. She discovered food delivery was her second biggest expense at ₹2,800 — more than her transport for the month. She decided to limit delivery to weekends only. Next month her food delivery spend was ₹900. She redirected the ₹1,900 difference into her emergency fund.',
    remember:
        'Review your finances for 10 minutes at the end of every month. One small decision made consistently changes everything.',
    ledgrrSees:
        'Your Statistics screen in LEDGRR is your CFO dashboard. Open it on the last day of every month and ask the three questions.',
  ),
];

// ─── SCREEN ────────────────────────────────────────────────────────────────

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  Set<String> _readLessons = {};
  bool _isLoading = true;

  final List<String> _levels = ['Foundation', 'Clarity', 'Mastery'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    try {
      final doc = await _db
          .collection('users')
          .doc(_uid)
          .collection('learn')
          .doc('progress')
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final read = (data['readLessons'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toSet();
        if (mounted) setState(() => _readLessons = read);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markRead(String lessonId) async {
    if (_readLessons.contains(lessonId)) return;
    setState(() => _readLessons.add(lessonId));
    await _db
        .collection('users')
        .doc(_uid)
        .collection('learn')
        .doc('progress')
        .set({
      'readLessons': _readLessons.toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  List<FinanceLesson> _lessonsForLevel(String level) =>
      _allLessons.where((l) => l.level == level).toList();

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;
    final total = _allLessons.length;
    final read = _readLessons.length;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Learn',
                          style: GoogleFonts.syne(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: palette.ink,
                              letterSpacing: -0.5)),
                      Text('Finance',
                          style: GoogleFonts.syne(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: palette.accent,
                              letterSpacing: -0.5)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: palette.bg2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$read of $total read',
                            style: GoogleFonts.syne(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: palette.accent)),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: total > 0 ? read / total : 0,
                              backgroundColor: palette.border,
                              valueColor: AlwaysStoppedAnimation(palette.accent),
                              minHeight: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Plain English. Real examples. Lessons that stick.',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: palette.inkMuted),
              ),
            ),

            const SizedBox(height: 16),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: palette.bg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: GoogleFonts.syne(
                      fontSize: 12, fontWeight: FontWeight.w700),
                  unselectedLabelStyle:
                      GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w500),
                  labelColor: palette.accentFg,
                  unselectedLabelColor: palette.inkMuted,
                  tabs: const [
                    Tab(text: 'Foundation'),
                    Tab(text: 'Clarity'),
                    Tab(text: 'Mastery'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Lesson lists
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: palette.accent, strokeWidth: 2))
                  : TabBarView(
                      controller: _tabController,
                      children: _levels.map((level) {
                        final lessons = _lessonsForLevel(level);
                        final levelRead =
                            lessons.where((l) => _readLessons.contains(l.id)).length;

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: lessons.length + 1,
                          itemBuilder: (context, i) {
                            if (i == lessons.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: palette.bg2,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: palette.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.auto_awesome_rounded,
                                          color: palette.accent, size: 16),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'More $level lessons coming soon.',
                                          style: GoogleFonts.dmSerifDisplay(
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic,
                                              color: palette.inkMuted),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final lesson = lessons[i];
                            final isRead = _readLessons.contains(lesson.id);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Material(
                                color: palette.card,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    _markRead(lesson.id);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => _LessonScreen(
                                          lesson: lesson,
                                          palette: palette,
                                          onRead: () => _markRead(lesson.id),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isRead
                                            ? palette.accent.withOpacity(0.3)
                                            : palette.border,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36, height: 36,
                                          decoration: BoxDecoration(
                                            color: isRead
                                                ? palette.accent
                                                : palette.bg2,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: isRead
                                                ? Icon(Icons.check_rounded,
                                                    color: palette.accentFg,
                                                    size: 16)
                                                : Text('${i + 1}',
                                                    style: GoogleFonts.syne(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: palette.inkMuted)),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(lesson.title,
                                                  style: GoogleFonts.syne(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w700,
                                                      color: palette.ink)),
                                              const SizedBox(height: 3),
                                              Text(lesson.hook,
                                                  style: GoogleFonts.syne(
                                                      fontSize: 11,
                                                      color: palette.inkMuted),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_ios_rounded,
                                            size: 12, color: palette.inkMuted),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── LESSON SCREEN ─────────────────────────────────────────────────────────

class _LessonScreen extends StatelessWidget {
  final FinanceLesson lesson;
  final LedgrrPalette palette;
  final VoidCallback onRead;

  const _LessonScreen({
    required this.lesson,
    required this.palette,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 0),
              child: Row(
                children: [
                  Material(
                    color: palette.bg2,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.arrow_back_rounded,
                            color: palette.ink, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: palette.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(lesson.level,
                          style: GoogleFonts.syne(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: palette.accent)),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title,
                        style: GoogleFonts.syne(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: palette.ink,
                            letterSpacing: -0.5,
                            height: 1.3)),
                    const SizedBox(height: 12),

                    // Hook
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.isDark ? palette.bg2 : palette.ink,
                        borderRadius: BorderRadius.circular(14),
                        border: palette.isDark
                            ? Border.all(color: palette.border)
                            : null,
                      ),
                      child: Text(
                        '"${lesson.hook}"',
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: palette.isDark ? palette.ink : Colors.white,
                            height: 1.5),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _sectionLabel('The concept', palette),
                    const SizedBox(height: 10),
                    Text(lesson.explanation,
                        style: GoogleFonts.syne(
                            fontSize: 14,
                            color: palette.ink,
                            height: 1.75)),

                    const SizedBox(height: 24),

                    _sectionLabel('Real life example', palette),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.bg2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: palette.border),
                      ),
                      child: Text(lesson.realLife,
                          style: GoogleFonts.syne(
                              fontSize: 13,
                              color: palette.ink,
                              height: 1.7,
                              fontStyle: FontStyle.italic)),
                    ),

                    const SizedBox(height: 24),

                    _sectionLabel('Remember this', palette),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: palette.accent.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded,
                              color: palette.accent, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(lesson.remember,
                                style: GoogleFonts.syne(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: palette.ink,
                                    height: 1.5)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _sectionLabel('What LEDGRR shows you', palette),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: palette.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: palette.accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: Text('RR',
                                  style: GoogleFonts.syne(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: palette.accent)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(lesson.ledgrrSees,
                                style: GoogleFonts.syne(
                                    fontSize: 13,
                                    color: palette.ink,
                                    height: 1.6)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Done button
                    Material(
                      color: palette.accent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          onRead();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text('Got it',
                                style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 17,
                                    fontStyle: FontStyle.italic,
                                    color: palette.accentFg)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, LedgrrPalette palette) {
    return Text(text,
        style: GoogleFonts.syne(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: palette.inkMuted,
            letterSpacing: 0.08));
  }
}