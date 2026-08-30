import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/spender_archetype_service.dart';

// ─── DATA ──────────────────────────────────────────────────────────────────
class LessonResource {
  final String title;
  final String author;
  final String note;
  const LessonResource({
    required this.title,
    required this.author,
    required this.note,
  });
}

class FinanceLesson {
  final String id;
  final String title;
  final String hook;
  final String level;
  final String explanation;
  final String realLife;
  final String remember;
  final String ledgrrSees;
  final List<LessonResource> resources;
  const FinanceLesson({
    required this.id,
    required this.title,
    required this.hook,
    required this.level,
    required this.explanation,
    required this.realLife,
    required this.remember,
    required this.ledgrrSees,
    this.resources = const [],
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
    resources: [
      LessonResource(
        title: 'I Will Teach You To Be Rich',
        author: 'Ramit Sethi',
        note: 'A practical, non-judgmental system for building a budget you can actually stick to.',
      ),
    ],
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
    resources: [
      LessonResource(
        title: 'Let\'s Talk Money',
        author: 'Monika Halan',
        note: 'An India-specific guide that builds everything on this exact equation.',
      ),
    ],
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
    resources: [],
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
    resources: [
      LessonResource(
        title: 'The Psychology of Money',
        author: 'Morgan Housel',
        note: 'Explains why starting early matters more than most people realize, through real stories.',
      ),
    ],
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
    resources: [],
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
    resources: [],
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
    resources: [
      LessonResource(
        title: 'The Psychology of Money',
        author: 'Morgan Housel',
        note: 'Has a strong chapter on how emotion, not logic, drives most spending decisions.',
      ),
    ],
  ),
  FinanceLesson(
    id: 'f8',
    level: 'Foundation',
    title: 'How a bank account actually works',
    hook: 'You have had a bank account for years. Do you actually know what it does?',
    explanation:
        'A savings account is where most students keep their money — it pays a small amount of interest and lets you withdraw anytime. A current account is for businesses and frequent high-value transactions — it pays no interest but has no withdrawal limits.\n\nYour IFSC code identifies your specific bank branch — you need it for anyone to transfer money to you via NEFT or RTGS. Your account number plus IFSC together are your complete banking address.\n\nNomination is the most skipped, most important feature. It names who receives your account balance if something happens to you. Most students never set one because it feels morbid or unnecessary at their age. It takes two minutes and it matters regardless of age — accidents and emergencies do not check your date of birth first.',
    realLife:
        'Rohan opened his first account at 18 and skipped the nomination step because the app made it optional. Three years later, filling it in took him two minutes when he finally got around to it — but for those three years, if anything had happened to him, his family would have faced a long legal process to claim his balance. Nomination costs nothing and takes minutes. There is no good reason to skip it.',
    remember:
        'Set your nomination the same day you open any account. Do not treat it as optional.',
    ledgrrSees:
        'LEDGRR tracks the money moving through your account. Understanding how the account itself works is the foundation everything else sits on.',
    resources: [
      LessonResource(
        title: 'RBI\'s official consumer education site',
        author: 'Reserve Bank of India',
        note: 'Plain-language explainers on how Indian banking actually works, from the source.',
      ),
    ],
  ),
  FinanceLesson(
    id: 'f9',
    level: 'Foundation',
    title: 'Lending and borrowing money without losing friends',
    hook: 'Money and friendship survive together only when both sides remember what was said.',
    explanation:
        'Lending or borrowing small amounts between friends is completely normal — splitting a bill, covering someone until payday, a quick loan for an emergency. The problem is never the money itself. It is the memory. One person remembers ₹500. The other remembers ₹300. Both are being honest — memory is just unreliable, especially for small amounts spread across weeks.\n\nThe awkwardness of asking "hey, you still owe me that ₹500" is real and it stops people from asking, which means debts quietly pile up and relationships quietly get strained. Writing it down the moment it happens removes the awkwardness entirely — it is not accusing anyone of anything, it is just a fact both people can check anytime.\n\nA simple rule: the moment money changes hands between friends, note it somewhere immediately. Not later. Immediately.',
    realLife:
        'Meera lent her roommate ₹2,000 over four separate occasions across two months — ₹500 here, ₹800 there, small amounts each time. Neither of them tracked it. When Meera finally brought it up, her roommate genuinely remembered a different, smaller number. It took an uncomfortable conversation and some awkwardness to sort out — friction that a simple running note would have avoided completely.',
    remember:
        'Track money between friends the moment it moves. It protects the friendship, not just the money.',
    ledgrrSees:
        'This is exactly what Dues Tracker in LEDGRR is for — log who owes you and who you owe the moment it happens, settle with a tap when it is paid back.',
    resources: [],
  ),
  FinanceLesson(
    id: 'f10',
    level: 'Foundation',
    title: 'UPI safety — the frauds every student falls for',
    hook: 'UPI never asks you to enter your PIN to receive money. Ever.',
    explanation:
        'The single most important UPI safety rule: you only ever enter your UPI PIN to send money, never to receive it. Any request, screen, or person telling you to "enter your PIN to receive ₹500" is a scam, no exceptions.\n\nCommon frauds targeting students: fake payment screenshots (someone shows you a doctored "payment successful" screenshot for something they never actually paid for), QR code scams (a scanned QR code that is actually a request to pay, not receive), and "wrong transfer, please refund" scams (someone sends you money then urgently asks you to refund to a different account — the original payment often bounces back or was fraudulent to begin with, leaving you having paid twice).\n\nOTPs are the same story — no bank, no UPI app, no "customer support" will ever call and ask for your OTP. If anyone asks, it is a scam, full stop.',
    realLife:
        'Kavya sold an old phone online. The buyer sent a screenshot claiming payment was done and asked her to ship the phone immediately since he was "in a hurry." She checked her actual bank app — nothing had arrived. The screenshot was fake, generated by an app designed to look exactly like a real payment confirmation. She almost shipped a phone for nothing.',
    remember:
        'Always check your own bank app for the money, never trust a screenshot someone else shows you.',
    ledgrrSees:
        'Log transactions in LEDGRR only after you have verified the money actually moved in your bank app — not based on what someone tells you or shows you.',
    resources: [
      LessonResource(
        title: 'RBI Sachet portal and consumer fraud advisories',
        author: 'Reserve Bank of India',
        note: 'Regularly updated, real examples of current UPI and banking scams circulating in India.',
      ),
    ],
  ),
  FinanceLesson(
    id: 'f11',
    level: 'Foundation',
    title: 'Setting a real financial goal (and actually hitting it)',
    hook: '"I want to save more" is not a goal. It is a wish.',
    explanation:
        'A real financial goal is specific, has a number, and has a deadline. "I want to save more" fails all three. "I want to save ₹6,000 for a trip in 4 months" succeeds at all three — and once it does, it becomes solvable. ₹6,000 over 4 months is ₹1,500 a month, or roughly ₹50 a day. Suddenly an overwhelming goal becomes a small, boring, doable daily number.\n\nThe common mistake is setting goals that are either too vague to act on or too ambitious to sustain. A goal that requires you to save 80% of your income for three months will fail by week two. A goal broken into small, realistic daily or weekly chunks is far more likely to actually happen.\n\nWriting the goal down somewhere visible — and tracking progress toward it — makes a measurable difference. Goals you can see are goals you are more likely to hit.',
    realLife:
        'Ananya wanted to buy a ₹12,000 laptop stand and accessories bundle for her final year project setup, but had no plan — just a vague hope she would "save up eventually." Three months later she had saved nothing, because there was no number to hit and no deadline pushing her. Once she set it as ₹12,000 in 3 months — roughly ₹4,000 a month — she hit it in exactly 11 weeks by treating it as a small non-negotiable transfer every payday.',
    remember:
        'Turn every vague money wish into a number and a deadline. That is the entire trick.',
    ledgrrSees:
        'This is exactly what Event Wallet in LEDGRR does — set a goal, a budget, and a date, and LEDGRR shows you how much to save per day to actually get there.',
    resources: [],
  ),
  FinanceLesson(
    id: 'f12',
    level: 'Foundation',
    title: 'Payslips and stipends — reading the fine print',
    hook: 'The number on your offer letter and the number in your bank account are rarely the same.',
    explanation:
        'Gross pay is the full amount before any deductions. Net pay — what actually lands in your bank account — is gross minus deductions like PF, professional tax, and TDS if applicable. For internships and stipends, always ask specifically: "what is the monthly amount that reaches my bank account?" A stipend letter that only states an annual or gross figure is easy to misread.\n\nRed flags in stipend or internship letters: no clear payment date mentioned, vague language like "compensation based on performance" with no minimum guaranteed, or a stipend paid only "at the end of the internship" with no interim payments. None of these are automatically scams, but all of them are worth clarifying in writing before you start, not after.\n\nAlways ask for anything financial in writing — email is fine, a verbal promise is not something you can reference later if something goes wrong.',
    realLife:
        'Vikram accepted an internship offer that verbally mentioned "₹15,000 stipend." He assumed this meant monthly. It turned out to be the total stipend for his entire 3-month internship — ₹5,000 a month. Nothing dishonest happened, but a simple written clarification upfront would have avoided the confusion and let him budget correctly from day one.',
    remember:
        'Get the exact monthly in-hand number in writing before you start any paid role, no matter how informal.',
    ledgrrSees:
        'Log your actual stipend or salary as it lands in LEDGRR — the real number, not the one from the offer letter — so your budget is built on reality.',
    resources: [],
  ),
  FinanceLesson(
    id: 'f13',
    level: 'Foundation',
    title: 'The 50/30/20 rule — a starting-point budget template',
    hook: 'You do not need a financial degree to build a budget. You need three buckets.',
    explanation:
        'The 50/30/20 rule is a simple starting template: 50% of your income toward needs (rent, food, transport, essentials), 30% toward wants (eating out, entertainment, shopping), and 20% toward savings and debt repayment.\n\nThis is a starting point, not a strict law — for a student living on a small allowance, 20% savings might not be realistic some months, and that is fine. The value of the rule is not the exact percentages, it is the habit of splitting income into three deliberate categories instead of one undifferentiated pool that disappears by month end.\n\nAdapt it: if your rent is unusually high relative to your income, your needs percentage will naturally be higher — that is normal and does not mean you are failing. The goal is intentional allocation, not perfect adherence to someone else\'s ratio.',
    realLife:
        'Siddharth earned ₹10,000 a month from a part-time job. Applying a rough 50/30/20 split: ₹5,000 to rent and food, ₹3,000 to wants, ₹2,000 to savings. Some months the split shifted — a higher rent month meant less for wants — but having the three-bucket structure meant he always knew roughly where he stood, instead of just watching the number in his account drop with no explanation.',
    remember:
        'Any consistent split beats no split at all. Start with 50/30/20 and adjust it to your real life.',
    ledgrrSees:
        'Use LEDGRR\'s categories to see your actual needs-vs-wants-vs-savings split each month under Statistics, and compare it to where you want it to be.',
    resources: [
      LessonResource(
        title: 'I Will Teach You To Be Rich',
        author: 'Ramit Sethi',
        note: 'Walks through building a personalized version of this exact bucket system.',
      ),
    ],
  ),
  FinanceLesson(
    id: 'f14',
    level: 'Foundation',
    title: 'Simple interest vs compound interest — the actual math',
    hook: 'Two words, two very different amounts of money.',
    explanation:
        'Simple interest is calculated only on your original amount, every time. Formula: Interest = Principal × Rate × Time. ₹10,000 at 5% simple interest for 3 years earns ₹500 every year, ₹1,500 total, no matter what.\n\nCompound interest is calculated on your original amount plus all previously earned interest. Formula: Amount = Principal × (1 + Rate)^Time. That same ₹10,000 at 5% compound interest for 3 years grows to ₹11,576 — earning ₹1,576, more than simple interest, because year 2 and year 3 interest is calculated on a growing amount, not the original ₹10,000 each time.\n\nThe gap seems small over 3 years. Over 20 years it becomes enormous — this is the entire mathematical reason "start early" is repeated so often in personal finance. It is not a platitude, it is the direct result of this formula.',
    realLife:
        'Comparing ₹1,00,000 invested for 20 years at 8%: under simple interest, it grows to ₹2,60,000. Under compound interest, it grows to ₹4,66,096. Same money, same rate, same time — an ₹2,06,096 difference purely from how the interest is calculated. This is why FDs, SIPs, and most real investments use compound interest, not simple interest.',
    remember:
        'Always ask whether a rate is simple or compound before comparing two financial products — they are not the same math.',
    ledgrrSees:
        'When comparing FD or SIP options for money sitting in your True Balance, always check whether the advertised rate is compounded and how often.',
    resources: [
      LessonResource(
        title: 'The Richest Man in Babylon',
        author: 'George S. Clason',
        note: 'A classic, story-based introduction to how compounding builds wealth over time.',
      ),
    ],
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
    resources: [],
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
    resources: [],
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
    resources: [],
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
    resources: [],
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
    resources: [],
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
    resources: [],
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
    resources: [],
  ),
  FinanceLesson(
    id: 'c8',
    level: 'Clarity',
    title: 'Your CIBIL score — the number that decides your future loans',
    hook: 'A three-digit number you have never checked is quietly deciding your future.',
    explanation:
        'Your CIBIL score is a number between 300 and 900 that tells lenders how likely you are to repay debt. Above 750 is considered good. It is built from your credit history — credit cards, loans, EMIs, and whether you paid on time.\n\nMost students have no credit history yet, which is normal — but it means your score starts mattering the moment you take your first credit card or education loan. Late payments, high credit card usage relative to your limit, and applying for many loans in a short time all hurt your score.\n\nA bad score later can mean rejected loan applications, higher interest rates, or needing a guarantor when you would not otherwise. Building good habits now — even before you have a credit card — sets you up well.',
    realLife:
        'Rohit applied for an education loan at 23 and was surprised to be offered a higher interest rate than his friend with an identical application. The difference: Rohit had missed two credit card payments in college, dragging his score down. His friend had none. Neither had thought about their score until that moment.',
    remember:
        'Check your CIBIL score for free once a year, even if you have never taken a loan. It is your financial reputation.',
    ledgrrSees:
        'Track any EMIs or credit card dues in LEDGRR so you never miss a payment date that could affect your score.',
    resources: [],
  ),
  FinanceLesson(
    id: 'c9',
    level: 'Clarity',
    title: 'Mutual funds explained without the jargon',
    hook: 'A mutual fund is just a lot of people pooling money to buy things together.',
    explanation:
        'A mutual fund pools money from many investors and a fund manager invests it in stocks, bonds, or both. You buy "units" of the fund — the price per unit is called NAV (Net Asset Value).\n\nEquity funds mostly buy stocks — higher risk, higher potential return, best for long-term goals (5+ years). Debt funds buy bonds and safer instruments — lower risk, lower return, better for short-term goals. Index funds simply copy a market index like the Nifty 50 instead of a manager picking stocks — usually cheaper and often perform just as well over time.\n\nExpense ratio is the yearly fee the fund charges you, as a percentage. A 1% expense ratio on a 12% return means you actually keep 11%. Lower is generally better, all else being equal.',
    realLife:
        'Kabir wanted to invest but was overwhelmed by hundreds of fund options. He learned that for a first-time investor with a long time horizon, a simple low-cost index fund covering the Nifty 50 was a reasonable, boring, sensible starting point — not the flashiest option, but not something he needed to overthink either.',
    remember:
        'You do not need to pick the "best" fund. A decent low-cost fund, invested consistently, beats a perfect fund you never start.',
    ledgrrSees:
        'Log your mutual fund SIP as a recurring expense in LEDGRR so it is treated as seriously as rent.',
    resources: [
      LessonResource(
        title: 'Let\'s Talk Money',
        author: 'Monika Halan',
        note: 'Has a clear, India-specific breakdown of fund types without unnecessary jargon.',
      ),
    ],
  ),
  FinanceLesson(
    id: 'c10',
    level: 'Clarity',
    title: 'Recurring Deposits vs FDs — which for which goal',
    hook: 'FDs want a lump sum. RDs want your monthly discipline.',
    explanation:
        'A Fixed Deposit needs a lump sum upfront, locked for a fixed tenure at a fixed rate. A Recurring Deposit lets you deposit a fixed amount every month instead — same idea, but built for people saving up gradually rather than people who already have the money sitting around.\n\nRDs are ideal when you do not have a lump sum but can commit to a monthly amount — saving toward a specific goal like a laptop or a trip. FDs are ideal when you already have a lump sum sitting idle and want it to grow safely.\n\nBoth are low-risk, both are better than a plain savings account for money you will not touch for months, and both offer guaranteed, predictable returns unlike mutual funds.',
    realLife:
        'Fatima wanted to save ₹24,000 for a laptop in a year but only had ₹3,000 to start. An RD of ₹2,000 a month for 12 months fit her actual situation far better than trying to force a lump-sum FD she did not have the money for yet.',
    remember:
        'No lump sum yet? RD. Already have one sitting idle? FD. Match the tool to your actual situation.',
    ledgrrSees:
        'Set an RD-style goal in LEDGRR\'s Event Wallet — a fixed monthly amount toward a specific target, tracked automatically.',
    resources: [],
  ),
  FinanceLesson(
    id: 'c11',
    level: 'Clarity',
    title: 'Digital gold, physical gold, gold ETFs — is gold actually a good investment',
    hook: 'Gold feels safe. Whether it actually is depends on what you are comparing it to.',
    explanation:
        'Physical gold (jewelry, coins) comes with making charges, storage risk, and purity concerns — it is more a cultural asset than a pure investment. Digital gold lets you buy small amounts online, backed by physical gold in a vault — more convenient, but usually has a buy-sell spread cutting into returns. Gold ETFs trade on the stock exchange like a share, backed by gold, often the most cost-efficient way to hold gold as a pure investment.\n\nHistorically, gold has returned roughly 8-10% annually over the long term in India — respectable, but generally lower than well-chosen equity mutual funds over 10+ year periods. Gold\'s real strength is as a hedge — it often holds value or rises when stock markets fall, which is why financial advisors suggest 5-10% of a portfolio in gold, not more.',
    realLife:
        'Zara\'s family always bought jewelry as "investment" for festivals. When she compared the actual returns after making charges to a gold ETF over the same period, the ETF had performed meaningfully better — with none of the storage risk or resale haggling that came with the jewelry.',
    remember:
        'Gold is a hedge, not a primary growth strategy. A small allocation makes sense; betting everything on it usually does not.',
    ledgrrSees:
        'If you invest in gold, log the purchase as an expense category in LEDGRR so it shows up in your overall financial picture, not hidden as a "gift" or untracked purchase.',
    resources: [],
  ),
  FinanceLesson(
    id: 'c12',
    level: 'Clarity',
    title: 'Understanding loans before you need one',
    hook: 'The best time to understand a loan is before you are desperate enough to sign anything.',
    explanation:
        'A loan\'s real cost is not just the interest rate — it is the interest rate, the processing fee, and whether interest is calculated on a flat or reducing balance. Reducing balance means interest is charged only on what you still owe, which is fairer and standard for most bank loans. Flat rate charges interest on the original amount for the entire tenure, which sounds similar but works out significantly more expensive — common in some personal loan and gadget financing schemes.\n\nEducation loans in India often have a moratorium period — you do not need to start repaying until after you finish your course, though interest may still accrue. Personal loans are unsecured, faster to get, and carry higher interest than secured loans like education or vehicle loans, because the bank has more risk.\n\nAlways calculate the total amount you will repay, not just the monthly EMI — a lower EMI over a much longer tenure can cost more overall.',
    realLife:
        'Yash needed ₹50,000 for a course and was offered "0% interest, easy EMI" by a gadget financing app. Reading the fine print, the "processing fee" and add-on charges meant the effective interest rate was over 20% — legally not called "interest" but functionally identical. A bank personal loan at 12% would have cost him far less overall.',
    remember:
        'Always ask for the total repayment amount and whether interest is flat or reducing — not just the advertised rate.',
    ledgrrSees:
        'Track any EMI as a recurring expense in LEDGRR so its true monthly cost against your True Balance is always visible.',
    resources: [],
  ),
  FinanceLesson(
    id: 'c13',
    level: 'Clarity',
    title: 'Term insurance vs health insurance — they are not the same thing',
    hook: 'One protects your family if you die. The other protects your money if you get sick.',
    explanation:
        'Health insurance pays for medical treatment — hospital bills, surgery, medicines. It protects your money while you are alive and unwell. Term insurance is life insurance that pays a lump sum to your family if you die during the policy term — it protects the people who depend on your income, not you.\n\nFor most students, term insurance is not yet urgent — it matters most once someone else depends on your income, like a spouse, child, or parents relying on you financially. Health insurance, by contrast, is relevant the moment you are financially independent or living away from family coverage — anyone can fall sick or get injured at any age.\n\nThe common confusion: some people buy expensive "insurance-cum-investment" products thinking they are getting both protection and growth. These usually perform worse at both jobs than buying pure term insurance and investing the difference separately in something like a mutual fund.',
    realLife:
        'Aryan\'s relative sold him an insurance policy that combined life cover with investment returns for ₹20,000 a year. When he compared it to buying a pure term plan for ₹6,000 a year and investing the remaining ₹14,000 in a mutual fund SIP, the separate approach came out significantly ahead on both the insurance cover amount and the investment growth.',
    remember:
        'Keep insurance and investment separate. Pure term insurance for protection, mutual funds or FDs for growth — mixing the two usually does both jobs poorly.',
    ledgrrSees:
        'Log any insurance premiums — health or term — as a yearly expense category in LEDGRR so you always see the real annual cost.',
    resources: [],
  ),
  FinanceLesson(
    id: 'c14',
    level: 'Clarity',
    title: 'Hostel vs PG vs renting — the real cost comparison',
    hook: 'Rent is never the only number. It is just the number everyone talks about.',
    explanation:
        'Hostel fees usually bundle rent and food into one number, making budgeting simple but offering little flexibility. PG (paying guest) accommodation often includes food and utilities with more independence than a hostel, at a moderate price. Renting your own place is the most independent but the least bundled — rent, electricity, water, wifi, gas, and maintenance are often all separate bills that add up fast and surprise first-time renters.\n\nWhen comparing options, always calculate the true total monthly cost — not just the headline rent. A "cheaper" rental can end up costing more than a PG once every separate bill is added up. Also factor in one-time costs: security deposits (often 2-3 months rent, refundable but ties up cash), brokerage fees, and initial setup costs for a bare rental.',
    realLife:
        'Ishaan compared a ₹6,000/month PG that included food and wifi against an ₹5,000/month bare rental. After adding electricity, water, wifi, gas, and groceries to the rental, his true monthly cost came to nearly ₹7,500 — more than the PG, despite the lower headline rent number.',
    remember:
        'Compare true total monthly cost, not headline rent. The cheapest-looking option is not always the cheapest.',
    ledgrrSees:
        'Log every housing-related expense — rent, utilities, wifi — under its own category in LEDGRR so your true monthly housing cost is always visible in Statistics.',
    resources: [],
  ),
  FinanceLesson(
    id: 'c15',
    level: 'Clarity',
    title: 'The financial documents every 18+ Indian needs',
    hook: 'A handful of documents quietly control almost everything financial in your life.',
    explanation:
        'PAN (Permanent Account Number) is required for almost any financial transaction above small amounts — opening a bank account, filing taxes, buying mutual funds, large purchases. Aadhaar is your identity document, now linked to most financial accounts by regulation. KYC (Know Your Customer) is the process of verifying your identity with these documents — every bank, mutual fund, and broker requires it before you can transact.\n\nMost students get a PAN card during college but do not think about it again until they need it urgently — for an internship stipend, a first salary, or opening an investment account. Getting these documents sorted early, before you urgently need them, avoids delays at exactly the moment you do not want them — like missing your first salary\'s tax deduction window or delaying your first investment.',
    realLife:
        'Neha got her first job offer and needed to submit her PAN details within a week for payroll setup. She had never applied for one. The wait for a new PAN card took over three weeks, delaying her first salary processing and creating an avoidable scramble in what should have been an exciting moment.',
    remember:
        'Get your PAN and complete your KYC before you need them urgently, not after.',
    ledgrrSees:
        'Once your documents are sorted, LEDGRR helps you track the income and investments that actually depend on having them ready.',
    resources: [],
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
    resources: [],
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
    resources: [],
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
    resources: [],
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
    resources: [],
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
    resources: [],
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
    resources: [],
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
    resources: [],
  ),
  FinanceLesson(
    id: 'm8',
    level: 'Mastery',
    title: 'EPF, PPF, NPS — India\'s retirement alphabet soup, decoded',
    hook: 'Retirement feels far away until the account you never opened would have been worth lakhs.',
    explanation:
        'EPF (Employee Provident Fund) is automatic once you have a salaried job — 12% of your basic salary goes in, your employer matches it, and it earns a government-set interest rate, currently around 8%. PPF (Public Provident Fund) is voluntary, open to anyone, with a 15-year lock-in and tax-free returns — a strong long-term, low-risk option even before you have a job. NPS (National Pension System) is market-linked, more flexible in contribution amount, and specifically designed for retirement with some tax benefits.\n\nThe key insight: these are not interchangeable, and starting even one of them early — especially PPF, which anyone can open regardless of employment status — takes advantage of decades of compounding before retirement even becomes a real thought.',
    realLife:
        'Tanvi opened a PPF account at 20 with just ₹500 a month, mostly because a relative suggested it. She barely thought about it for years. By the time she checked at 35, 15 years of compounding at a government-backed rate had turned a small, barely-noticed habit into a meaningful sum — without her ever making an active investment decision after the initial setup.',
    remember:
        'You do not need a job to start a PPF account. Fifteen years of compounding started at 20 is worth far more than the same fifteen years started at 30.',
    ledgrrSees:
        'Log any PPF or NPS contributions as a savings category in LEDGRR alongside your other investments for the full picture.',
    resources: [],
  ),
  FinanceLesson(
    id: 'm9',
    level: 'Mastery',
    title: 'How to actually buy your first stock',
    hook: 'Buying a stock is less complicated than the process makes it feel.',
    explanation:
        'To buy stocks in India you need a Demat account (holds your shares electronically) and a trading account (executes buy/sell orders) — most brokers bundle both together during signup, requiring PAN, Aadhaar, and a bank account.\n\nT+1 settlement means when you buy a stock, it reflects in your Demat account the next working day — not instantly. A market order buys or sells immediately at the current price; a limit order only executes at a price you specify, giving you control but no guarantee of execution.\n\nFor a first-time investor, the honest advice is: individual stock-picking requires real time and research to do well, and most people — even professionals — underperform a simple index fund over the long run. Starting with an index fund and only later exploring individual stocks once you have the interest and time to research properly is a reasonable, unglamorous path.',
    realLife:
        'Dev opened a Demat account after watching finance influencers and bought three stocks based on tips he saw online, with no research of his own. A year later, two were down significantly. He later realized that the time he spent chasing tips would have been better spent simply investing consistently in an index fund and learning at his own pace.',
    remember:
        'Opening a Demat account is easy. Picking good individual stocks consistently is genuinely hard — do not confuse the two.',
    ledgrrSees:
        'Whatever you invest — stocks, funds, or otherwise — log it as an expense in LEDGRR so your True Balance always reflects money that has left your spending pool.',
    resources: [
      LessonResource(
        title: 'One Up On Wall Street',
        author: 'Peter Lynch',
        note: 'A classic, readable introduction to how individual stock investing actually works, and its real demands.',
      ),
    ],
  ),
  FinanceLesson(
    id: 'm10',
    level: 'Mastery',
    title: 'Negotiating your first salary offer',
    hook: 'The number on your offer letter is usually not the company\'s final number. It is their opening one.',
    explanation:
        'Most companies expect some negotiation, especially for experienced hires — for freshers there is often less room, but it still exists more often than students assume. What is usually negotiable: joining bonus, start date, sometimes base salary within a band. What is usually fixed: the overall CTC band for a fresher role at a given level, especially at large companies with structured pay scales.\n\nThe biggest mistake is negotiating based on what you need rather than what the market pays for the role — research what similar roles at similar companies typically offer before any conversation. The second biggest mistake is accepting or rejecting on the spot — it is always reasonable to ask for a day or two to review an offer in writing.\n\nNegotiating respectfully and based on research rarely costs you an offer that was genuine to begin with.',
    realLife:
        'Riya received an offer and almost accepted immediately out of excitement and fear of losing it. A mentor suggested she simply ask if there was any flexibility on the joining bonus, citing a slightly higher competing offer. The company increased it by ₹20,000 with no drama — money she would have left on the table by not asking.',
    remember:
        'It rarely hurts to politely ask. The worst outcome is usually just "no," not a withdrawn offer.',
    ledgrrSees:
        'Once you have your actual offer, log the real in-hand monthly figure in LEDGRR — not the negotiated headline CTC — to build your real budget.',
    resources: [],
  ),
  FinanceLesson(
    id: 'm11',
    level: 'Mastery',
    title: 'Side hustles and multiple income streams — done right',
    hook: 'A second income stream is powerful. An untracked, untaxed one is a future problem.',
    explanation:
        'Freelancing, tutoring, content creation, and gig work are increasingly common ways students build income beyond a stipend or allowance. Done well, these build both money and real-world skills. Done carelessly, they create two common problems: no separation between "hustle money" and personal spending, and no awareness of tax obligations once income crosses certain thresholds.\n\nEven informal freelance income is technically taxable in India once your total annual income crosses the basic exemption limit — many students are unaware of this until much later. Keeping a simple, separate record of side-hustle income from day one — even before it is large — makes tax filing and financial planning dramatically easier later, rather than trying to reconstruct a year of scattered UPI payments after the fact.',
    realLife:
        'Ayaan did freelance graphic design alongside college, earning irregular amounts from different clients via UPI. He never tracked it separately from his personal spending. When he eventually needed to understand his actual annual income for a loan application, reconstructing a year of mixed personal and freelance transactions took him an entire weekend that a simple separate log from the start would have avoided entirely.',
    remember:
        'Track side income separately from day one, however small. Future-you filing taxes or applying for a loan will be grateful.',
    ledgrrSees:
        'Log freelance or side-hustle income as its own category in LEDGRR so it is never mixed up with your primary income when you need the real numbers.',
    resources: [],
  ),
  FinanceLesson(
    id: 'm12',
    level: 'Mastery',
    title: 'Is real estate actually a good investment for someone your age',
    hook: 'Everyone\'s uncle has an opinion about property. Few have actually run the numbers.',
    explanation:
        'Real estate is often treated as the default "safe" investment in Indian culture, but the honest math is more nuanced for someone in their 20s. Property requires a large lump sum or a long-term loan commitment, is illiquid (you cannot sell part of a house quickly if you need cash), and carries ongoing costs — maintenance, property tax, and sometimes years without rental income if unoccupied.\n\nHistorically, well-chosen equity mutual funds have often outperformed real estate returns over long periods once you account for property\'s illiquidity, maintenance costs, and the opportunity cost of a large locked-up down payment. This does not mean real estate is a bad choice — it can make sense for specific goals like eventually owning a home to live in — but "property always goes up" is not a complete financial analysis on its own.',
    realLife:
        'Kunal\'s family encouraged him to save every rupee toward a property down payment starting at 22, discouraging any mutual fund investment as "risky" by comparison. When he compared the historical performance of consistent equity SIP investing against typical real estate appreciation over the same period, accounting for property\'s illiquidity and upkeep costs, the numbers were closer — and considerably more flexible — than the family\'s assumption suggested.',
    remember:
        'Real estate can be part of a plan, but "it always goes up" is folklore, not analysis. Run the actual numbers before committing a decade of savings to it.',
    ledgrrSees:
        'Whatever your long-term investment mix, track it consistently in LEDGRR so you can honestly compare how different choices are actually performing over time.',
    resources: [],
  ),
  FinanceLesson(
    id: 'm13',
    level: 'Mastery',
    title: 'What a recession actually means for you',
    hook: 'A recession on the news feels abstract until it is a hiring freeze at the company you applied to.',
    explanation:
        'A recession is a sustained period of economic decline — typically shrinking GDP, rising unemployment, and reduced spending. For someone early in their career, the practical effects usually show up as: hiring freezes or slower job offers, layoffs at companies that overhired during good times, and more competition for fewer open roles.\n\nThis is precisely why an emergency fund matters more, not less, for young people — a recession is exactly the scenario an emergency fund exists for. It is also why avoiding high-interest debt and building some savings buffer early is not paranoid, it is preparation for a genuinely normal part of economic cycles that repeats every several years.\n\nDuring downturns, markets often fall too — which, uncomfortable as it feels, is also historically when long-term investors who keep investing consistently (rather than panic-selling) tend to benefit most once markets recover.',
    realLife:
        'Simran graduated during a hiring slowdown and watched several friends face delayed joining dates or rescinded offers. She had built a small emergency fund during her final year internship, which meant the uncertain few months of job searching were stressful but not financially desperate — unlike friends with no buffer who had to borrow to cover basic expenses.',
    remember:
        'An emergency fund is not pessimism. It is what makes a bad economic stretch survivable instead of catastrophic.',
    ledgrrSees:
        'Keep an eye on your emergency fund progress in LEDGRR\'s Event Wallet — it matters most in exactly the moments you cannot predict.',
    resources: [],
  ),
  FinanceLesson(
    id: 'm14',
    level: 'Mastery',
    title: 'Wills and nominations — why 22-year-olds should still care',
    hook: 'Nobody wants to think about this. That is exactly why most people never do.',
    explanation:
        'A nomination (covered briefly in an earlier lesson) names who receives a specific account\'s balance if something happens to you — quick, simple, and something every bank account, mutual fund, and insurance policy should have filled in. A will is broader — a legal document specifying how all your assets should be distributed, which matters more as your assets and responsibilities grow, but is worth understanding even now.\n\nFor a 22-year-old with modest savings, an emergency fund, and maybe a small investment portfolio, a formal will may not be urgent yet — but understanding the difference between nomination and a will (a nomination does not override legal inheritance rights the way many assume) avoids a common and costly misunderstanding for later in life.\n\nThe real lesson at this age is simpler: make sure every account has a nomination filled in, and understand that "I will deal with this later" is exactly how important-but-not-urgent things get permanently postponed.',
    realLife:
        'Arnav assumed that because he had named his sister as nominee on his bank account, that settled everything about what would happen to all his assets if something happened to him. He later learned that nomination and legal inheritance are not the same thing — a nominee is often just a trustee for the actual legal heirs, not automatically the final owner. Understanding this distinction now, while his assets were still small, cost him nothing and taught him something that matters far more later.',
    remember:
        'Nomination and a will are different things. Understand the difference now, even if you do not need a formal will yet.',
    ledgrrSees:
        'While LEDGRR cannot manage legal documents, tracking your growing net worth here is exactly the kind of awareness that eventually makes a proper will worth setting up.',
    resources: [],
  ),
  FinanceLesson(
    id: 'm15',
    level: 'Mastery',
    title: 'Reading a mutual fund factsheet',
    hook: 'A factsheet has one job: to help you compare funds honestly. Most people never open one.',
    explanation:
        'A mutual fund factsheet is a document every fund publishes monthly, and it contains the numbers that actually matter for comparison. CAGR (Compound Annual Growth Rate) shows the fund\'s average yearly return over a period — more meaningful than a single year\'s return, which can be misleadingly high or low. Expense ratio is the yearly fee, directly reducing your returns. Exit load is a fee charged if you withdraw before a certain period, discouraging short-term in-and-out behavior. Benchmark is the index the fund is measured against — a fund consistently beating its benchmark over multiple years is doing its job; one consistently underperforming it usually is not worth the higher fees active funds often charge over simpler index funds.\n\nMarketing materials often highlight the single best-performing year. A factsheet, read properly, shows the fuller, more honest multi-year picture instead.',
    realLife:
        'Ishita was choosing between two funds recommended by an advertisement highlighting one fund\'s standout single year. Pulling up both funds\' actual factsheets, she found the "standout" fund had a notably higher expense ratio and had underperformed its benchmark over the full 5-year period — the marketing had simply cherry-picked its best year rather than telling the complete story.',
    remember:
        'Always check the multi-year CAGR against the benchmark and the expense ratio — not just the number in the advertisement.',
    ledgrrSees:
        'Whichever funds you choose, LEDGRR helps you see the discipline side of investing — consistent logging and tracking — while the factsheet handles the fund-quality side.',
    resources: [],
  ),
    // ── NEW ARCHETYPE-SPECIFIC LESSONS ─────────────────────────────────────
  FinanceLesson(
    id: 'new_recognizing_triggers',
    level: 'Foundation',
    title: 'Recognizing your personal spending triggers',
    hook: 'You don\'t spend when you\'re hungry. You spend when you\'re something else.',
    explanation:
        'Most impulsive spending is not actually about the item at all. It is a response to a feeling — stress after an exam, boredom on a slow evening, loneliness after a fight with a friend, or the urge to celebrate after something good happened. The purchase is a shortcut to changing how you feel, right now, in the next five minutes.\n\nThe problem is not that these feelings exist. Everyone feels them. The problem is when spending becomes the automatic response every single time, without you ever noticing the pattern forming underneath it.\n\nOnce you can actually name your own trigger, you get a choice you did not have before. You can recognize the feeling arriving and decide, on purpose, whether spending is really what you want to do about it — instead of finding yourself mid-checkout before you have even registered why.',
    realLife:
        'Meher noticed she always ordered dessert delivery on nights she felt anxious about an upcoming deadline. Once she named it — "I do this specifically when I am anxious, not when I am hungry" — she started noticing the urge arrive a few seconds before she acted on it. That small gap gave her a moment to choose something else, and sometimes she still chose the dessert, but now it was a decision instead of a reflex.',
    remember:
        'The trigger itself is not the problem. Not noticing the trigger is.',
    ledgrrSees:
        'Check your LEDGRR transaction timestamps against how your week was actually going. Spending spikes often line up with specific kinds of days, not random chance.',
  ),
  FinanceLesson(
    id: 'new_inconsistent_logging_cost',
    level: 'Foundation',
    title: 'Why inconsistent logging costs more than you think',
    hook: 'A number you don\'t check can\'t warn you.',
    explanation:
        'Logging transactions inconsistently feels harmless in the moment — surely you will remember the big stuff. But small, forgotten transactions are exactly the ones that add up silently: the ₹40 here, the ₹120 there, never individually big enough to remember, always adding up to something real by the time the month closes.\n\nThere is a second, quieter cost too. Every feature that makes LEDGRR genuinely useful — True Balance, Ghost Money Detector, spending pattern insights — depends entirely on real data to work correctly. Logging inconsistently does not just blur your own memory of the month. It blinds the exact tools built to protect you from the mistakes that inconsistent tracking causes in the first place.',
    realLife:
        'Yusuf logged his transactions "whenever he remembered," roughly every few days. When he finally checked his real monthly total, it was nearly ₹1,800 higher than his own mental estimate — almost entirely small purchases he had genuinely, honestly forgotten by the time he got around to logging them.',
    remember:
        'Log it in the moment, not "later." Later rarely happens accurately, no matter how good your intentions are.',
    ledgrrSees:
        'Your streak counter in LEDGRR is not really about guilt — it is a direct, honest measure of how much you can actually trust your own True Balance right now.',
  ),
  FinanceLesson(
    id: 'new_two_minute_log',
    level: 'Foundation',
    title: 'The two-minute log — making tracking too easy to skip',
    hook: 'The habit that survives is the one that takes the least effort.',
    explanation:
        'Logging habits fail most often not because people do not care, but because the habit feels like a chore that can always be postponed. Reducing it down to a genuine two-minute action — done the exact moment money moves, not batched up for later — removes the mental excuse to skip it entirely.\n\nThe fewer steps and the less thought required, the more likely any habit survives a genuinely busy or exhausting day. A habit that requires remembering, opening an app, and carefully filling in details feels different from one that takes two taps and is simply done.',
    realLife:
        'Aisha used to "batch" her logging for the weekend, telling herself she would remember everything. Once she realized same-moment logging genuinely took only seconds each time, while catching up later took nearly an hour of guessing and reconstructing, she switched entirely to logging the instant a payment happened.',
    remember:
        'The easier a habit is, the more likely it survives an ordinary, busy day.',
    ledgrrSees:
        'LEDGRR\'s Quick Add exists specifically to make same-moment logging effortless — use it right when the payment happens, not when you finally get a free moment.',
  ),
  FinanceLesson(
    id: 'new_lose_by_not_knowing',
    level: 'Foundation',
    title: 'What you lose by not knowing your own numbers',
    hook: 'You can\'t fix a leak you can\'t see.',
    explanation:
        'Not knowing your real spending is often treated as a neutral, harmless gap — but it is actually an active cost. Every financial decision made without real numbers in front of you is essentially a guess, and guesses about money tend to be wrong in the expensive direction, not the safe one.\n\nThe uncomfortable truth is that "I think I have enough" and "I actually have enough" are two completely different statements, and only one of them protects you from an overdraft, a bounced payment, or an awkward moment splitting a bill you cannot actually cover.',
    realLife:
        'Rehan assumed he had "enough" in his account for a purchase he had been planning. He genuinely did not. Not knowing his real number cost him an overdraft fee that a habit of accurate, current tracking would have prevented entirely, with zero extra effort beyond simply checking first.',
    remember:
        'Not knowing your numbers is never neutral. It is a guess, and guesses cost money.',
    ledgrrSees:
        'Every logged transaction in LEDGRR replaces a guess with a fact. The more consistently you log, the fewer expensive guesses you are making.',
  ),
  FinanceLesson(
    id: 'new_logging_as_trigger',
    level: 'Foundation',
    title: 'Turning logging into a trigger, not a task',
    hook: 'Attach the habit to something you already do, and it stops needing willpower.',
    explanation:
        'New habits stick far more reliably when they are attached to an existing routine, rather than floating on their own as one more thing to remember. Logging a transaction right when you put your phone away after paying is a very different mental experience from telling yourself you will "log it sometime today."\n\nThis is a well-studied idea in habit formation — the existing action becomes the trigger for the new one, and eventually the two feel like a single motion rather than two separate steps requiring separate willpower.',
    realLife:
        'Devika tied her logging habit to the exact moment she locked her phone screen after completing any UPI payment. Within about two weeks, the sequence had become so automatic she genuinely could not complete a payment without also opening LEDGRR right after, without even consciously deciding to.',
    remember:
        'Attach a new habit to an old one you already do without thinking. That is the entire trick.',
    ledgrrSees:
        'Try logging in LEDGRR the instant a payment completes, using whatever moment already exists in your routine — locking your phone, closing the payment app, whatever comes naturally.',
  ),
  FinanceLesson(
    id: 'new_reconstruct_untracked_month',
    level: 'Foundation',
    title: 'Reconstructing a month you never tracked',
    hook: 'A missed month isn\'t lost. It just takes longer to see.',
    explanation:
        'If an entire month went completely untracked, the instinct is often to give up on that period entirely and just start fresh going forward. But pulling your actual bank statement and logging the major transactions retroactively is genuinely worth the twenty minutes it takes.\n\nImperfect, reconstructed data beats no data at all, and more importantly, it stops the exact same gap from quietly repeating itself next month too, since you will have actually looked closely at what happened rather than simply moving on.',
    realLife:
        'Kabir rebuilt an entirely skipped month using his bank app\'s own transaction history, which took him about twenty minutes total. That single exercise was enough to spot two forgotten subscriptions he would otherwise have completely missed, since he had never sat down to actually review that period closely before.',
    remember:
        'A gap in your data is fixable with a bit of effort. A gap you never bother filling just quietly repeats itself.',
    ledgrrSees:
        'Back-date transactions in LEDGRR when reconstructing a missed period, so your Statistics screen reflects what actually happened, not a suspicious blank month.',
  ),
  FinanceLesson(
    id: 'new_debt_map',
    level: 'Clarity',
    title: 'The debt map — seeing everyone you owe in one place',
    hook: 'Debt spread across five people feels smaller than debt owed to one bank. It isn\'t.',
    explanation:
        'When money is owed to several different friends separately, it becomes surprisingly easy to underestimate the real total, simply because no single number ever appears in one place at once. Each individual debt feels small and manageable on its own.\n\nListing every single debt together, with actual amounts attached, is the necessary first step to genuinely managing the situation rather than continuing to feel vaguely uneasy about scattered, half-remembered amounts owed to different people.',
    realLife:
        'Nikhil realized, once he actually sat down and added it all up, that his "small" individual debts to four different friends totaled ₹4,200 — a number far higher than he had estimated when thinking about each debt separately in his head.',
    remember:
        'Debt does not become smaller just because it is split across multiple people. Add it up honestly.',
    ledgrrSees:
        'Dues Tracker in LEDGRR already lists every single debt in one consolidated place — use it as your actual, honest debt map, not just a list of individual reminders.',
  ),
  FinanceLesson(
    id: 'new_juggling_costs_more',
    level: 'Clarity',
    title: 'Why juggling multiple debts costs more than one bigger one',
    hook: 'Five small debts create five separate chances to forget one.',
    explanation:
        'Having multiple simultaneous debts to different people increases both the mental load of remembering them all correctly and the real chance of missing a repayment entirely — straining more relationships at once than a single larger, clearly tracked debt ever would.\n\nEach additional lender adds an entirely separate thread to keep straight in your head, and human memory is genuinely not built to reliably track several independent running totals at the same time without some kind of external system helping.',
    realLife:
        'Sana was simultaneously juggling debts to three different friends and consistently paid back the wrong person first on two separate occasions, creating real, unnecessary friction and confusion in relationships that a single consolidated list would have prevented entirely.',
    remember:
        'More lenders means more chances to forget one. Consolidate what you genuinely can.',
    ledgrrSees:
        'Review all your open dues together in LEDGRR before deciding which one to settle first, rather than tackling them from scattered memory.',
  ),
  FinanceLesson(
    id: 'new_snowball_method',
    level: 'Clarity',
    title: 'The snowball method — paying off small debts first',
    hook: 'Momentum, not math, is what actually gets debt paid off.',
    explanation:
        'The snowball method means deliberately paying off your smallest debt first, regardless of its interest rate, and then rolling that same payment amount into tackling the next smallest debt. The psychological win of genuinely closing out a debt quickly tends to keep motivation alive far more reliably than the mathematically "optimal" order of attacking the highest-interest debt first.\n\nPersonal finance is not purely a math problem — it is also a behavior problem, and a method that keeps you actually continuing beats a theoretically perfect method that you abandon halfway through out of discouragement.',
    realLife:
        'Priyank cleared his smallest ₹500 debt first and felt a genuine, immediate sense of progress that motivated him to keep going, rather than feeling overwhelmed trying to attack his largest debt head-on from the very start.',
    remember:
        'A quick, visible win keeps you going. Perfect math that quietly discourages you is not actually optimal in practice.',
    ledgrrSees:
        'Settle your smallest open due in LEDGRR first, and use that genuine momentum to carry you into the next one.',
  ),
  FinanceLesson(
    id: 'new_stop_new_debt_first',
    level: 'Clarity',
    title: 'Stopping new debt before old debt is settled',
    hook: 'You can\'t pay off debt while still adding to it.',
    explanation:
        'Borrowing from a new person while still owing money to an older one keeps your total debt quietly growing even as you feel like you are making progress by settling individual pieces here and there. The genuine first step is not repayment at all — it is a firm, deliberate stop on taking on anything new until the existing situation is under control.\n\nWithout that stop, repayment efforts end up treading water, since new debt keeps arriving roughly as fast as old debt gets cleared.',
    realLife:
        'Farah kept borrowing small amounts from new friends even while slowly repaying older debts to others, and her total amount owed never actually shrank overall, despite genuinely feeling like she was "handling it" the whole time.',
    remember:
        'Real repayment progress only works if the total amount owed actually stops growing first.',
    ledgrrSees:
        'Check your total "I owe" figure in LEDGRR\'s Dues Tracker honestly before agreeing to borrow again from anyone new.',
  ),
  FinanceLesson(
    id: 'new_wont_happen_to_me',
    level: 'Foundation',
    title: 'The "it won\'t happen to me" math',
    hook: 'Nobody plans for an emergency. That\'s exactly why it\'s called one.',
    explanation:
        'Believing a genuine crisis will not happen to you personally is an extremely normal, common bias — but the underlying math of emergencies does not actually care about how anyone feels about their own odds. A genuinely unplanned cost eventually reaches nearly everyone at some point, and preparing for it in advance is far cheaper than being caught completely without any buffer when it actually arrives.\n\nThe "unlikely" emergency scenario is not actually unlikely in aggregate — it is simply one that any specific person has not personally experienced yet.',
    realLife:
        'Aakriti never genuinely believed she would need an emergency fund until a sudden medical bill arrived and made her realize the "unlikely" scenario had simply been one she had not personally lived through before that point.',
    remember:
        'An emergency fund is not pessimism about your own life. It is simply accepting the math that applies to everyone.',
    ledgrrSees:
        'Start an Emergency Fund jar in LEDGRR even with a genuinely small first deposit — starting matters more than the initial size.',
  ),
  FinanceLesson(
    id: 'new_build_ef_without_deprivation',
    level: 'Clarity',
    title: 'Building your emergency fund without feeling deprived',
    hook: 'An emergency fund doesn\'t require sacrifice. It requires patience.',
    explanation:
        'Building an emergency fund only feels daunting when it is approached as one large, intimidating lump sum that has to appear all at once. A small, steady, genuinely boring contribution spread out over many months achieves exactly the same end result, without requiring any dramatic change to your actual day-to-day lifestyle.\n\nThe emotional resistance to saving usually comes from imagining the full target amount all at once, rather than the small, easily absorbed monthly piece that actually gets you there.',
    realLife:
        'Rehaan saved just ₹300 a month specifically toward his emergency fund and reached ₹10,000 in under three years, without ever feeling like he was meaningfully sacrificing anything noticeable along the way.',
    remember:
        'Small and steady genuinely beats big and sacrificial, because steady is the version that actually continues long enough to work.',
    ledgrrSees:
        'Set a modest, comfortable recurring deposit into your LEDGRR Emergency Fund jar, rather than waiting until you have a large amount to start with.',
  ),
  FinanceLesson(
    id: 'new_what_counts_as_emergency',
    level: 'Foundation',
    title: 'What actually counts as an emergency (and what doesn\'t)',
    hook: 'A sale is not an emergency. Neither is an opportunity.',
    explanation:
        'An emergency fund only genuinely works as intended if its definition stays strict and consistent — real medical costs, a sudden loss of income, essential and urgent repairs. The moment "amazing deal" or "once in a lifetime opportunity" gets quietly allowed in as a valid reason to dip into it, the fund stops functioning as insurance and starts functioning as just another, slightly-harder-to-reach spending account.\n\nThe entire value of the fund depends on this boundary holding firm, even when something genuinely tempting comes along that does not actually qualify.',
    realLife:
        'Tanish nearly used his emergency fund for a "limited time only" gadget sale before catching himself and realizing that was not remotely what the fund actually existed for. Two months later, that same intact fund covered a genuine, unplanned emergency exactly as it was meant to.',
    remember:
        'If a purchase is genuinely optional, it is not an emergency — no matter how urgent it feels in the moment.',
    ledgrrSees:
        'Before withdrawing from an Emergency Fund jar in LEDGRR, honestly ask yourself whether this situation fits the strict definition, not the tempting one.',
  ),
  FinanceLesson(
    id: 'new_default_opt_out_trap',
    level: 'Foundation',
    title: 'The default opt-out trap',
    hook: 'The businesses behind free trials know memory fails. That\'s the whole model.',
    explanation:
        'Free trials are deliberately designed to automatically convert into paid subscriptions unless you take active steps to cancel, precisely because the business behind them knows that most people will simply forget to do so in time. Understanding this default setting is the necessary first step toward actually beating it.\n\nThis is not an accidental design flaw on the company\'s part — it is the entire, intentional business model behind a huge portion of the subscription economy.',
    realLife:
        'Ronit signed up for three separate "free for 7 days" trials over a period of a few months, genuinely intending to cancel each one before it converted. He forgot every single time, and all three quietly became ongoing recurring charges without him noticing for months.',
    remember:
        'The default setting is specifically designed to work against your memory. Set your own explicit reminder instead of relying on remembering.',
    ledgrrSees:
        'Log the exact trial end date as a note in LEDGRR the very moment you start any free trial, so you have an external reminder instead of relying on memory alone.',
  ),
  FinanceLesson(
    id: 'new_why_ignore_same_alert',
    level: 'Foundation',
    title: 'Why you keep ignoring the same alert',
    hook: 'Seeing a warning and acting on it are two completely different skills.',
    explanation:
        'A Ghost Money alert that keeps getting repeatedly dismissed usually means the noticing part of the system is working perfectly fine — the real gap is that the deciding part never actually happens afterward. The genuine fix here is not a smarter or louder alert, it is committing to an actual decision the very moment you see the alert appear.\n\nDismissing something is a passive action that requires almost no effort, which is exactly why it becomes a comfortable, repeated habit that quietly avoids the real decision entirely.',
    realLife:
        'Devika\'s Ghost Money Detector flagged the exact same forgotten subscription three separate months in a row. Each time, she noticed it, felt a small flash of mild annoyance, and simply moved on without actually deciding anything concrete about it.',
    remember:
        'Noticing an alert is genuinely not the same thing as acting on it.',
    ledgrrSees:
        'Treat every single Ghost Money flag in LEDGRR as requiring one of exactly two actions: cancel the charge, or consciously and deliberately decide to keep it.',
  ),
  FinanceLesson(
    id: 'new_3strike_rule',
    level: 'Foundation',
    title: 'The 3-strike rule for dismissed alerts',
    hook: 'If you\'ve dismissed the same alert three times, dismissing isn\'t working.',
    explanation:
        'A useful personal rule: if the exact same recurring charge gets flagged and then dismissed on three separate, distinct occasions, the next time it appears, the only permitted action becomes either cancelling it outright or explicitly deciding to keep it for good. No more quiet, repeated dismissing without a real decision attached.\n\nThis rule works because it converts an indefinitely repeatable passive habit into a hard, one-time forced decision point that cannot simply be postponed again.',
    realLife:
        'Omkar deliberately set himself this exact rule and finally cancelled a genuinely unused subscription on its third flag, after two full months of passively dismissing it without any real change in behavior at all.',
    remember:
        'Three dismissals in a row is a genuine pattern, not a coincidence. Force yourself into a real decision on the third one.',
    ledgrrSees:
        'Notice how many times the same Ghost Money alert has already repeated in LEDGRR before automatically dismissing it again without thinking.',
  ),
  FinanceLesson(
    id: 'new_autopay_not_autopilot',
    level: 'Foundation',
    title: 'Auto-pay is not the same as auto-pilot',
    hook: 'Automatic payment doesn\'t mean automatic awareness.',
    explanation:
        'Setting a payment to auto-deduct is genuinely convenient, but it also quietly removes the one natural moment where you would normally have noticed the charge happening at all. Auto-pay genuinely needs its own separate, deliberate check-in habit built specifically to replace that lost moment of awareness — otherwise the payment simply becomes invisible.\n\nThe convenience of automation and the awareness of manual payment are two entirely separate things, and losing the second one is a real, if easily overlooked, cost of gaining the first.',
    realLife:
        'Simar had five separate auto-pay subscriptions running and genuinely could not list even half of them from memory when directly asked, simply because none of them had ever required her active attention to actually happen each month.',
    remember:
        'Automating a payment means you must also deliberately automate the review of it, or it disappears from your awareness entirely.',
    ledgrrSees:
        'Use LEDGRR\'s Ghost Money Detector specifically as the review step that auto-pay itself quietly skips over on its own.',
  ),
  FinanceLesson(
    id: 'new_awareness_to_cancellation',
    level: 'Foundation',
    title: 'Turning awareness into an actual cancellation',
    hook: 'Knowing about the leak and fixing the leak are separated by exactly one action.',
    explanation:
        'The genuine gap between thinking "I really should cancel this" and actually cancelling it is usually just the mild, ordinary friction of opening an app and locating the correct cancel button. Naming clearly that this really is the only remaining step often makes it noticeably easier to just go ahead and do it immediately, right in the same moment.\n\nThe imagined difficulty of cancelling is almost always larger in someone\'s head than the genuine, small effort actually required in reality.',
    realLife:
        'Yamini knew about a specific unused subscription for several months before finally realizing that cancelling it would take well under two minutes, once she actually opened the relevant app to check exactly what was involved.',
    remember:
        'The cancel button is very rarely as far away, or as complicated, as it feels from the outside.',
    ledgrrSees:
        'When LEDGRR flags a Ghost Money hit, treat that exact same session as the moment to actually cancel it, not just as a moment to quietly notice it again.',
  ),
  FinanceLesson(
    id: 'new_forgotten_trial',
    level: 'Foundation',
    title: 'The forgotten trial — how free trials become permanent bills',
    hook: 'Nobody signs up for a subscription. They sign up for a free trial and forget to cancel it.',
    explanation:
        'Nearly every silent recurring charge that quietly drains an account started life as a completely free trial that someone genuinely intended to cancel before it converted. The businesses behind these trials know perfectly well that memory fails people reliably, which is exactly why the default setting is to auto-charge unless you take the active step of opting out.\n\nThis pattern repeats itself across streaming services, software tools, and countless apps, precisely because it works reliably from the business\'s perspective.',
    realLife:
        'Tanish signed up for three separate free trials over a period of several months, each time genuinely intending to cancel before the trial period ended. Eight months later, all three had quietly become permanent, ongoing charges without him noticing until he finally reviewed his statement closely.',
    remember:
        'The moment you start any free trial, set an actual, real reminder — not just a vague mental note to "remember."',
    ledgrrSees:
        'Log the exact trial end date as a note directly in LEDGRR, so Ghost Money Detector has a genuine head start on catching it later if you do happen to forget.',
  ),
  FinanceLesson(
    id: 'new_recurring_audit',
    level: 'Foundation',
    title: 'Auditing your recurring payments in 15 minutes',
    hook: 'Once a quarter, spend 15 minutes finding out what you\'re actually paying for.',
    explanation:
        'A recurring payment audit is genuinely simple in practice: once every three months, list out every subscription and recurring charge you can currently identify, next to an honest note of how recently you actually used each one. Anything genuinely unused within the last 30 days gets cancelled outright, with no exceptions made for "maybe I will use it again someday."\n\nThis single, repeated habit, done consistently over time, catches nearly every silent financial leak well before it has a chance to become a long-term, unnoticed drain on your money.',
    realLife:
        'Priyanka started a genuine quarterly 15-minute audit habit after being genuinely shocked by her own forgotten subscriptions on one particular occasion. Every single audit since that first one has found at least one more thing genuinely worth cancelling, proving that the underlying leak never fully stops appearing on its own without ongoing attention.',
    remember:
        'This is not a one-time fix you complete and forget about. New forgotten subscriptions keep quietly appearing over time regardless.',
    ledgrrSees:
        'Set a genuine recurring reminder tied to your LEDGRR streak to review Ghost Money Detector every three months, whether or not it currently appears to be flagging anything.',
  ),
  FinanceLesson(
    id: 'new_your_new_networth_story',
    level: 'Mastery',
    title: 'Your new net worth story, post-ghost',
    hook: 'The money that used to leak is now money you get to direct on purpose.',
    explanation:
        'Once a recurring financial leak is genuinely closed, that freed-up amount deserves an explicit, deliberate destination — otherwise it simply gets quietly absorbed back into ordinary, undirected spending with absolutely nothing to show for the effort of catching it in the first place.\n\nThe moment of cancelling a leak is genuinely the perfect moment to make a second decision immediately: exactly where should this freed money now go instead. Skipping that second decision is how a real win quietly disappears into nothing.',
    realLife:
        'After cancelling a forgotten ₹499 monthly subscription, Aarav redirected that exact freed amount into his SIP the very same day, rather than letting it dissolve gradually into unplanned, unremarkable spending over the following weeks.',
    remember:
        'Freed money needs a job assigned the moment it is freed, or it disappears the exact same quiet way it originally arrived.',
    ledgrrSees:
        'When you cancel a Ghost Money hit in LEDGRR, immediately redirect that exact amount into a Jar or an investment category the same day.',
  ),
  FinanceLesson(
    id: 'new_redirect_saved_money',
    level: 'Mastery',
    title: 'Redirecting saved money instead of letting it disappear',
    hook: 'Money saved by accident is still money that can be saved on purpose.',
    explanation:
        'When a recurring leak genuinely stops, the natural human tendency is for the freed monthly amount to simply get quietly spent elsewhere without anyone consciously deciding that should happen. Actively and deliberately redirecting that freed amount into a specific named goal turns what was a one-time accidental fix into ongoing, compounding progress.\n\nThe difference between "I saved money this month" and "I am now saving this money every month going forward" is entirely the presence or absence of this one deliberate redirect decision.',
    realLife:
        'Meher cancelled two genuinely unused subscriptions in the same week and immediately set up an automatic transfer of the exact combined freed amount into her Trip Fund jar, all within the same session.',
    remember:
        'A stopped leak is only a genuine long-term win if the freed money goes somewhere deliberate and specific.',
    ledgrrSees:
        'Create or top up a Jar in LEDGRR the very same day you cancel a Ghost Money hit, rather than leaving the freed amount undirected.',
  ),
  FinanceLesson(
    id: 'new_ghost_to_growth',
    level: 'Mastery',
    title: 'From ghost money to growth money',
    hook: 'The same rupee that was leaking can be the rupee that compounds.',
    explanation:
        'Money that once silently drained an account through a forgotten recurring charge can, once redirected into a SIP or a genuine savings goal, become the exact same amount doing the completely opposite job — growing steadily over time instead of quietly disappearing every single month.\n\nThe underlying cash flow does not actually change at all. What changes entirely is the direction that same flow of money is now pointed in, which over years makes an enormous practical difference to the eventual outcome.',
    realLife:
        'Kartik\'s freed ₹300 monthly subscription cost became his new monthly SIP contribution amount, meaning the exact same rupee flow that used to vanish every month now steadily built real, growing wealth instead.',
    remember:
        'The actual amount rarely needs to change. Only its direction genuinely does.',
    ledgrrSees:
        'Log your redirected Ghost Money savings as a recurring investment category in LEDGRR so the shift in direction is genuinely visible over time.',
  ),
  FinanceLesson(
    id: 'new_vigilant_after_winning',
    level: 'Mastery',
    title: 'Staying vigilant after you\'ve already won once',
    hook: 'Fixing one leak doesn\'t mean there won\'t be a second.',
    explanation:
        'Genuine success at catching and fixing one recurring charge can create a subtle, false sense that the entire problem has now been permanently solved for good. In reality, new trials, new subscriptions, and new recurring charges keep quietly appearing over time regardless of past wins, so the same underlying vigilance genuinely needs to continue rather than relax.\n\nOne successful catch proves the system works. It does not prove the underlying problem has been eliminated for the future.',
    realLife:
        'Sanya felt genuinely proud after successfully cancelling a forgotten subscription, then let her guard down for several months afterward, until an entirely new and different subscription had quietly started up without her noticing at all.',
    remember:
        'Fixing one leak does not mean the pipe itself is done leaking forever.',
    ledgrrSees:
        'Keep checking Ghost Money Detector in LEDGRR on a regular, ongoing basis, even well after a past successful catch.',
  ),
  FinanceLesson(
    id: 'new_old_ghosts_return',
    level: 'Mastery',
    title: 'Why old ghosts sometimes come back',
    hook: 'Cancelling a subscription doesn\'t vaccinate you against re-subscribing later.',
    explanation:
        'A previously cancelled subscription can genuinely and quietly return if you re-sign-up for a "limited time offer" or promotional deal months later, without consciously remembering the original reason you had cancelled it in the first place.\n\nThis specific pattern is easy to overlook precisely because the second subscription genuinely feels like a fresh, new decision, rather than a repeat of exactly the same mistake made once before.',
    realLife:
        'Rohan cancelled a streaming service entirely, then re-subscribed several months later for a tempting "free month" promotional offer and simply forgot to cancel it again afterward, recreating the exact identical financial leak he had already solved once before.',
    remember:
        'A ghost you have already dealt with once can genuinely still come back if you are not paying close attention the second time around.',
    ledgrrSees:
        'Check LEDGRR\'s transaction history periodically for any previously-cancelled charges that may have quietly restarted without you noticing.',
  ),
  FinanceLesson(
    id: 'new_fixed_leak_funded_goal',
    level: 'Mastery',
    title: 'Turning a fixed leak into a funded goal',
    hook: 'Every leak you close is a goal waiting to be named.',
    explanation:
        'Rather than treating a fixed subscription leak as simply "one less bad thing happening now," it is genuinely more powerful to treat it as freed-up money actively looking for a specific, positive, named purpose — an emergency fund, a trip, an investment, anything concrete rather than nothing at all.\n\nNaming the destination transforms a purely negative fix (stopping a bad thing) into a positive, forward-looking action (building a good thing), which tends to feel far more motivating and sustainable over time.',
    realLife:
        'Farhan named his freed-up ₹250 monthly leak specifically as his "concert fund," giving the newly saved money a clear, tangible identity instead of letting it simply blend anonymously back into his general, undirected spending.',
    remember:
        'Give freed money an actual name and a specific purpose. Unnamed money tends to quietly get spent.',
    ledgrrSees:
        'Create a specific Jar or Event Wallet in LEDGRR, named directly after whatever your freshly-freed Ghost Money is now genuinely funding.',
  ),
  FinanceLesson(
    id: 'new_other_dangerous_category',
    level: 'Foundation',
    title: 'Why "Other" is the most dangerous category in your budget',
    hook: '"Other" isn\'t a category. It\'s a category you haven\'t looked at yet.',
    explanation:
        'A genuinely bloated "Other" category quietly means a meaningful portion of your overall spending has become effectively invisible to you, even though the spending itself has already, definitely happened either way. The only real difference between a healthy category system and a bloated "Other" bucket is whether you can actually see the underlying pattern or not.\n\nAn oversized "Other" category is rarely a sign that your spending is unusually chaotic — it is far more often simply a sign that your labeling habit has quietly fallen behind your actual spending habit.',
    realLife:
        'Om noticed his "Other" category was consistently his third-largest expense category every single month, and upon finally investigating closely, found it was almost entirely food delivery he had simply been too rushed or too lazy to properly categorize at the time.',
    remember:
        'If "Other" is genuinely bigger than any of your named categories, that is precisely the real story you are currently missing.',
    ledgrrSees:
        'Check your category breakdown directly in LEDGRR Statistics specifically for an unusually oversized "Other" slice.',
  ),
  FinanceLesson(
    id: 'new_15min_recategorization',
    level: 'Foundation',
    title: 'The 15-minute recategorization habit',
    hook: 'Fixing bad labels takes less time than living with them for a year.',
    explanation:
        'Setting aside 15 minutes once a month specifically to review anything logged under "Other" and properly reassign it a real, specific category is a genuinely small habit that prevents your single biggest blind spot from quietly growing indefinitely, month after month.\n\nThe recurring nature of this habit matters more than any single cleanup session, since new uncategorized transactions keep arriving every single month regardless of how thoroughly you cleaned up the last one.',
    realLife:
        'Ishaan\'s monthly 15-minute recategorization session consistently revealed that most of his "Other" spending was actually one single specific habit he had genuinely never bothered naming properly before, month after month.',
    remember:
        'A small, recurring 15-minute habit genuinely beats one overwhelming once-a-year cleanup attempt.',
    ledgrrSees:
        'Review and properly edit any uncategorized or "Other" transactions inside LEDGRR on a genuine monthly basis.',
  ),
  FinanceLesson(
    id: 'new_biggest_unlabeled_category',
    level: 'Foundation',
    title: 'What your biggest unlabeled category is really telling you',
    hook: 'The things you don\'t bother labeling are often the things you don\'t want to look at closely.',
    explanation:
        'People often leave a spending category deliberately vague specifically at the exact moments when the underlying spending feels a little uncomfortable to name directly and honestly. Being genuinely honest about what "Other" actually, specifically contains is frequently more revealing than reviewing any of your properly named categories.\n\nVague labeling is rarely a purely random accident — it often quietly protects the labeler from having to consciously confront a pattern they already suspect exists.',
    realLife:
        'Zara eventually realized her unusually large "Other" category was almost entirely made up of late-night impulse purchases that she had been subconsciously avoiding naming directly and specifically for months.',
    remember:
        'Vague labels often quietly hide exactly the spending you most genuinely need to see clearly.',
    ledgrrSees:
        'Be genuinely specific when categorizing transactions in LEDGRR, even in moments when the honest, accurate label feels a little uncomfortable to select.',
  ),
  FinanceLesson(
    id: 'new_categories_matching_life',
    level: 'Foundation',
    title: 'Building categories that actually match your life',
    hook: 'Generic categories fit nobody perfectly. Custom ones fit you.',
    explanation:
        'Default expense categories in any app are necessarily built for an imagined average user, not specifically for your own real, particular life and habits. Renaming existing categories or thoughtfully adding new ones that genuinely reflect your actual recurring spending patterns makes the entire habit of tracking meaningfully more useful and accurate over time.\n\nA category system that does not genuinely match your real life will always feel slightly, persistently wrong, even if you cannot immediately articulate exactly why it feels that way.',
    realLife:
        'Riya added a specific "hostel mess extras" category since it represented a genuinely recurring pattern that none of the default categories had captured well, which immediately and noticeably made her overall spending picture clearer.',
    remember:
        'A category system that does not genuinely match your real life will always feel a little bit wrong, no matter how you use it.',
    ledgrrSees:
        'Use LEDGRR\'s category options thoughtfully, deliberately picking or creating ones that genuinely reflect your own actual, specific spending patterns.',
  ),
    FinanceLesson(
    id: 'new_cost_of_vague_labels',
    level: 'Foundation',
    title: 'The cost of vague labels',
    hook: 'A vague label costs you the insight the data could have given you.',
    explanation:
        'Logging a transaction under a vague label like "misc" or "stuff" technically does track the money leaving your account, but it genuinely throws away almost all the useful information about exactly where that money actually went, which defeats a large part of the entire point of tracking in the first place.\n\nThe extra few seconds it takes to pick an accurate, specific category is a small, one-time cost that pays off every single time you later look back at your Statistics and want the numbers to actually mean something.',
    realLife:
        'Dev logged his transactions vaguely for several months in a row, only to realize at his first real review session that the vague labels told him almost nothing genuinely useful about his own actual spending habits, despite the money itself having been tracked accurately the entire time.',
    remember:
        'Tracking money without also labeling it specifically and accurately is genuinely only half of the actual job.',
    ledgrrSees:
        'Take the extra few seconds inside LEDGRR to pick the genuinely accurate category, not simply whichever one happens to be fastest to tap.',
  ),
  FinanceLesson(
    id: 'new_i_dont_know_where_it_went',
    level: 'Foundation',
    title: 'Turning "I don\'t know where it went" into an answer',
    hook: 'That feeling is fixable. It just requires looking, not guessing.',
    explanation:
        'The genuinely uneasy, nagging feeling of not knowing exactly where your money went is almost always solvable simply by actually sitting down and reviewing your labeled data properly, rather than continuing to quietly guess or feel vaguely anxious about it indefinitely.\n\nThe anxiety itself often persists far longer than the actual investigation would take, purely because most people avoid opening the numbers up and looking directly, rather than because the answer is genuinely hard to find once you do.',
    realLife:
        'Nisha finally sat down one evening and properly reviewed her actual categorized spending instead of continuing to simply worry vaguely about it, and found a clear, genuinely fixable answer within about ten minutes of actually looking.',
    remember:
        'The anxious feeling of not knowing is usually resolved far faster than expected, the moment you actually sit down and look.',
    ledgrrSees:
        'Open LEDGRR Statistics the very next time you notice that specific "where did it all go" feeling arriving, instead of continuing to simply wonder about it.',
  ),
  FinanceLesson(
    id: 'new_24hr_rule',
    level: 'Clarity',
    title: 'The 24-hour rule for impulse purchases',
    hook: 'If you still want it tomorrow, buy it tomorrow.',
    explanation:
        'For any genuinely non-essential purchase above a personal threshold amount you decide on in advance, deliberately waiting a full 24 hours before actually buying it creates a clean separation between a passing emotional spike and a genuine, lasting desire, since only real desire reliably survives an entire day intact.\n\nThe waiting period itself costs nothing except a small amount of patience, while genuinely protecting against the large majority of purchases that would otherwise have been quietly regretted within a day or two.',
    realLife:
        'Simran committed firmly to waiting a full 24 hours on anything priced over ₹500, and found that she genuinely no longer wanted most of those specific items by the very next day, once the initial emotional urgency had naturally faded.',
    remember:
        'Urgency around a purchase is very often manufactured. Genuine desire reliably survives a full day intact.',
    ledgrrSees:
        'Before logging a clear impulse buy in LEDGRR, honestly ask yourself whether you would genuinely have wanted to log this exact same purchase yesterday too.',
  ),
  FinanceLesson(
    id: 'new_replace_reward',
    level: 'Clarity',
    title: 'Replacing the reward, not the spending',
    hook: 'You don\'t need to stop rewarding yourself. You need a reward that doesn\'t cost money every time.',
    explanation:
        'Comfort spending is very often a genuine, functioning reward system where the actual reward simply happens to cost money each time it is triggered. Deliberately finding a non-spending reward that delivers a similarly genuine emotional payoff removes the ongoing cost entirely, without removing the underlying comfort or relief you were genuinely seeking.\n\nThe goal is never to eliminate the reward itself, since the underlying need for comfort or relief is completely real and valid — the goal is simply to find a version of that same reward that does not quietly drain money every single time it happens.',
    realLife:
        'Yamini deliberately replaced her habitual post-stress food delivery order with a specific phone call to her best friend instead, and found the genuine emotional relief nearly identical in practice, minus the recurring financial cost that used to come with it.',
    remember:
        'The underlying craving is genuinely for relief, not specifically for the act of spending money itself.',
    ledgrrSees:
        'Notice which specific spending categories tend to spike right after a genuinely hard day in your LEDGRR history — that pattern is your current, real reward system in action.',
  ),
  FinanceLesson(
    id: 'new_what_buying_comfort',
    level: 'Clarity',
    title: 'What you\'re actually buying when you buy comfort',
    hook: 'Nobody actually wants the dessert. They want the five minutes where nothing else matters.',
    explanation:
        'Deliberately naming the real underlying thing you are actually seeking beneath a comfort purchase — distraction, a sense of control, a small quick win, a moment of pure focus — makes it genuinely possible to go looking for that specific thing directly, rather than continuing to route every single version of that need through spending money.\n\nMost comfort purchases are standing in for something else entirely that has very little to do with the actual item being purchased.',
    realLife:
        'Rajat eventually realized his habitual late-night shopping sessions were really, underneath everything, about wanting to feel a sense of control during otherwise chaotic days, and found several genuinely free alternative ways to create that exact same feeling for himself instead.',
    remember:
        'Ask yourself honestly what you are actually buying underneath the purchase. It is very rarely the literal item sitting in your cart.',
    ledgrrSees:
        'When reviewing a comfort purchase logged in LEDGRR, try writing one single honest word describing what you were actually genuinely seeking in that moment.',
  ),
  FinanceLesson(
    id: 'new_friday_spike',
    level: 'Foundation',
    title: 'The Friday spike — why weekends cost more than you plan for',
    hook: 'Your budget assumes every day costs the same. Weekends disagree.',
    explanation:
        'Weekend spending very often silently dominates an entire monthly budget without ever being explicitly, deliberately planned for in advance, largely because Friday-to-Sunday plans tend to get decided socially and spontaneously in the moment, rather than being budgeted for ahead of time the way weekday spending often is.\n\nA budget built around an assumption of roughly equal daily spending will consistently and predictably fail to account for this very common, very real weekend concentration effect.',
    realLife:
        'Ibrahim discovered, once he actually looked closely at his own numbers, that his weekends alone accounted for well over half of his entire monthly spending, despite representing only two out of every seven days each week.',
    remember:
        'If weekends are not explicitly, deliberately planned for in advance, they will very quietly eat the rest of your entire monthly budget.',
    ledgrrSees:
        'Check your LEDGRR transaction dates specifically for a noticeable Friday-to-Sunday clustering pattern across a typical month.',
  ),
  FinanceLesson(
    id: 'new_plan_fun_not_overspend',
    level: 'Clarity',
    title: 'Planning fun without planning to overspend',
    hook: 'The goal isn\'t less fun. It\'s fun that doesn\'t derail the rest of your month.',
    explanation:
        'Deciding roughly how much you are comfortable spending socially before the weekend even begins, rather than simply reacting to plans as they arrive one by one, genuinely keeps the actual enjoyment fully intact while still protecting the rest of your monthly budget from unplanned damage.\n\nA small amount of upfront planning does not meaningfully reduce spontaneity or fun — it simply removes the anxious uncertainty of not knowing what a weekend actually cost until well after the fact.',
    realLife:
        'Kavya started setting a rough, loose weekend spending number for herself every single Friday morning, and found she genuinely enjoyed her weekends just as much as before, while consistently staying comfortably within her overall monthly budget.',
    remember:
        'A small amount of planning done before the fun actually starts genuinely protects the fun itself, rather than limiting it.',
    ledgrrSees:
        'Set yourself a rough personal weekend spending limit and track it directly against your actual LEDGRR weekend transactions as the days unfold.',
  ),
  FinanceLesson(
    id: 'new_weekday_discipline_weekend_blind',
    level: 'Clarity',
    title: 'Weekday discipline, weekend blindness',
    hook: 'Discipline that only shows up five days a week isn\'t discipline for the whole budget.',
    explanation:
        'It is genuinely quite common to feel financially disciplined based purely on careful weekday behavior alone, while weekend spending quietly runs on an entirely separate, completely unmonitored set of habits that never actually gets the same level of honest scrutiny.\n\nA feeling of overall discipline built on only five out of seven days is fundamentally incomplete, since the remaining two days can easily undo a substantial portion of the careful progress made during the rest of the week.',
    realLife:
        'Aryan genuinely felt proud of his careful, disciplined weekday spending habits, without initially realizing that his weekends alone were quietly undoing most of that same careful discipline every single week.',
    remember:
        'Discipline only genuinely counts toward your overall budget if it actually covers the whole week, not just the more convenient part of it.',
    ledgrrSees:
        'Honestly compare your LEDGRR weekday spending totals against your weekend totals to see the real, complete picture.',
  ),
  FinanceLesson(
    id: 'new_treat_yourself_cost',
    level: 'Clarity',
    title: 'The cost of "treating yourself" every week',
    hook: 'A weekly treat is still a monthly habit with a monthly price tag.',
    explanation:
        'A small weekly "treat" genuinely feels harmless and insignificant in any single moment, but once multiplied out across four or five weekends in a typical month, it quietly becomes a real, recurring line item that is genuinely worth seeing as one single combined number rather than several separate small ones.\n\nThe psychological trick here is that each individual instance feels too small to matter, while the honest monthly total often tells a genuinely different, more significant story.',
    realLife:
        'Meher\'s seemingly "small" ₹400 weekly treat quietly added up to somewhere between ₹1,600 and ₹2,000 every single month once properly totaled — a number that genuinely surprised her once she actually sat down and calculated it honestly.',
    remember:
        'Multiply your "small" weekly habit by four before deciding, with real confidence, that it is genuinely small.',
    ledgrrSees:
        'Total your recurring weekend treat category directly inside LEDGRR Statistics across one full month to see the real, honest number.',
  ),
  FinanceLesson(
    id: 'new_weekend_cap',
    level: 'Clarity',
    title: 'Setting a weekend cap that still feels like fun',
    hook: 'A limit isn\'t the enemy of fun. An unplanned overspend is.',
    explanation:
        'Setting a specific weekend spending cap decided calmly in advance genuinely does not reduce your actual enjoyment of the weekend itself — it simply prevents the guilt and stressful damage-control that typically follows an unplanned overspend only discovered well after the fact, once the fun has already ended.\n\nA cap set in advance changes the entire emotional experience of spending from anxious and reactive to calm and intentional, even when the total amount spent ends up being roughly similar either way.',
    realLife:
        'Farah set herself a firm ₹1,000 weekend cap and found she could still genuinely, fully enjoy her usual plans, but now carried an underlying awareness throughout that made the following week noticeably less stressful than usual.',
    remember:
        'A planned limit genuinely protects your fun. An unplanned overspend simply delays the resulting stress to later.',
    ledgrrSees:
        'Set yourself a personal weekend cap and check it directly against your live, running LEDGRR weekend total as the weekend actually unfolds.',
  ),
  FinanceLesson(
    id: 'new_midmonth_cliff',
    level: 'Foundation',
    title: 'The mid-month cliff — why week one decides your whole month',
    hook: 'By the 10th, you already know how the 30th is going to feel.',
    explanation:
        'Heavily front-loaded spending is genuinely, at its core, a first-week problem that simply carries month-long consequences forward with it. The most effective fix is therefore specifically protecting that critical first week from absorbing spending that was actually meant to be spread out across the entire month.\n\nOnce the first week consumes a disproportionate share of the monthly budget, the remaining three weeks are mathematically forced into an uncomfortable, anxious scramble that could have been entirely avoided with slightly better early pacing.',
    realLife:
        'Rehan consistently spent nearly half of his entire monthly allowance within just the first five days, every single month. Deliberately capping his specific first-week spending removed the genuinely anxious, tight second half of his month almost entirely.',
    remember:
        'Watch your first week of any month closely, as if it were the whole month playing out in miniature.',
    ledgrrSees:
        'Check your transaction dates directly inside LEDGRR Statistics for any noticeable early-month spending clustering pattern.',
  ),
  FinanceLesson(
    id: 'new_envelope_method',
    level: 'Foundation',
    title: 'The envelope method — giving every rupee a job before you spend it',
    hook: 'Money without a job assigned to it gets spent on whatever shows up first.',
    explanation:
        'Mentally dividing your income into clearly named pots the very moment it actually arrives creates a genuine, natural pause before spending from the wrong one, since each rupee now has a specific, assigned job rather than simply sitting undesignated in one large, undifferentiated pool.\n\nThis classic budgeting method works precisely because it forces a small moment of conscious awareness at the point of spending, rather than only revealing the consequences much later when the month\'s totals are finally reviewed.',
    realLife:
        'Farah started splitting her allowance into clearly named categories on the very day it arrived each month, and noticed herself genuinely hesitating before overspending from the wrong specific envelope, simply because the boundary now actually existed in her mind.',
    remember:
        'Money without an assigned job is genuinely the easiest kind of money to accidentally misspend.',
    ledgrrSees:
        'Use LEDGRR\'s categories as your own personal envelopes, setting a rough monthly limit for each one as your actual guide.',
  ),
  FinanceLesson(
    id: 'new_weekly_reset',
    level: 'Foundation',
    title: 'The weekly reset — pacing spending instead of front-loading it',
    hook: 'A monthly budget with no weekly checkpoints is just a number you\'ll ignore until it\'s too late.',
    explanation:
        'Deliberately breaking a single monthly budget down into four smaller weekly chunks creates genuinely frequent checkpoints along the way, so that a single bad week gets caught and corrected early enough to actually matter, rather than only being discovered as part of an already-bad month once it is far too late to meaningfully fix.\n\nA purely monthly number is simply too slow and too distant to meaningfully influence behavior in the moment. A weekly number is fast enough to actually still change what happens next.',
    realLife:
        'Ibrahim split his overall monthly budget into four distinct weekly targets and, as a direct result, caught a genuinely overspending week early enough to meaningfully adjust his following week\'s spending in response.',
    remember:
        'A purely monthly number is too slow to genuinely help you in the moment. A weekly number is fast enough to actually matter.',
    ledgrrSees:
        'Check your running LEDGRR "Spent" total every few days throughout the month, rather than only waiting patiently for the month to fully close.',
  ),
    FinanceLesson(
    id: 'new_fair_share_split',
    level: 'Foundation',
    title: 'Splitting bills without resentment — the fair-share method',
    hook: 'Splitting evenly isn\'t always splitting fairly.',
    explanation:
        'Splitting a shared bill based on what each individual person actually ordered or consumed takes only about thirty extra seconds of simple arithmetic, and it genuinely prevents the slow, quiet resentment that purely equal-splitting habits tend to build up gradually over many repeated occasions.\n\nEqual splitting feels simpler in the moment, but when one person consistently orders less than everyone else, the small unfairness compounds silently over time into a genuine, if rarely voiced, source of friction.',
    realLife:
        'Nihal\'s regular friend group eventually switched over to itemized, actual-consumption splitting, and the quiet resentment he realized he had been carrying for several months simply disappeared entirely once the system genuinely felt fair to everyone involved.',
    remember:
        'A thirty-second calculation done in the moment genuinely prevents months of accumulated, silent resentment later on.',
    ledgrrSees:
        'Log your own actual, specific share of any group bill in LEDGRR, rather than automatically logging the simple even split.',
  ),
  FinanceLesson(
    id: 'new_saying_no_plan',
    level: 'Foundation',
    title: 'Saying no to a plan you can\'t afford',
    hook: 'Every yes to a plan you can\'t afford is a no to something else that mattered more.',
    explanation:
        'A clear, simple, direct no to an expensive plan genuinely costs nothing socially in the vast majority of real situations, while quietly agreeing to attend and then privately scrambling financially afterward costs both real money and real, lasting stress.\n\nMost people significantly overestimate how much a simple, honest decline will actually bother their friends, when in reality most friends genuinely do not think about it nearly as much or as long as the person declining fears they will.',
    realLife:
        'Lavanya started simply saying "I am going to skip this one" without offering any lengthy explanation or justification, and found that nobody actually reacted anywhere near as negatively as she had originally, anxiously feared they might.',
    remember:
        'A clear no costs you genuinely nothing lasting. A yes you truly cannot afford costs you both real money and real stress.',
    ledgrrSees:
        'Check your actual True Balance directly inside LEDGRR before agreeing to any noticeably expensive upcoming plan.',
  ),
  FinanceLesson(
    id: 'new_cost_keeping_up',
    level: 'Clarity',
    title: 'The cost of keeping up with your friend group',
    hook: 'Your friends\' spending habits are not your budget.',
    explanation:
        'Spending money specifically to match the pace and habits of a friend group very rarely feels like a genuinely conscious, deliberate choice in the moment, but the uncomfortable reality is that everyone within that same group may be operating on very different real incomes entirely, invisible from the outside.\n\nComparing your own spending directly to your friends\' visible spending is comparing yourself to a number you genuinely do not have full access to, since you rarely know their actual complete financial picture behind the scenes.',
    realLife:
        'Rudra had been quietly straining financially to match his friend group\'s regular restaurant habits, without initially realizing that two of them had part-time jobs specifically funding that exact shared lifestyle, which he did not have himself.',
    remember:
        'You are never actually competing directly against your friends\' spending — only against your own real, personal numbers.',
    ledgrrSees:
        'Track your social spending as its own distinct category in LEDGRR so you can see its genuine, honest size clearly over time.',
  ),
  FinanceLesson(
    id: 'new_enjoy_going_out',
    level: 'Clarity',
    title: 'How to enjoy going out without derailing your month',
    hook: 'The goal isn\'t to stop going out. It\'s to go out on purpose.',
    explanation:
        'Deciding roughly how much social spending genuinely fits comfortably within your overall month before that month even begins lets you say yes to spontaneous plans without the quiet, nagging dread of wondering afterward exactly what each outing actually cost you.\n\nThe anxiety around social spending very often comes not from the spending itself, but from the complete absence of any prior plan to compare it against once the bill actually arrives.',
    realLife:
        'Vidya set herself a loose, rough monthly social spending target at the very start of the month and found she genuinely enjoyed her various outings noticeably more, specifically because she was no longer privately worrying about the true cost every single time.',
    remember:
        'Deciding your rough social budget in advance genuinely turns going out from an anxious risk into a comfortable, pre-approved plan.',
    ledgrrSees:
        'Set yourself a rough monthly social spending target and honestly track it against LEDGRR\'s actual categorized spending data.',
  ),
  FinanceLesson(
    id: 'new_untracked_income_disappears',
    level: 'Clarity',
    title: 'Why untracked income disappears faster than tracked income',
    hook: 'Money you didn\'t plan for is money you don\'t notice leaving either.',
    explanation:
        'Irregular income that never gets logged as its own separate, distinct category tends to blend invisibly into regular, everyday spending, effectively disappearing without ever having been consciously and deliberately allocated toward anything specific in particular.\n\nMoney that arrives unexpectedly seems to carry an unspoken permission to be spent just as unexpectedly, purely because it was never given a proper name or destination the moment it actually arrived.',
    realLife:
        'Kiara\'s occasional freelance payments used to quietly vanish into her everyday daily spending until she deliberately started logging them as their own distinct category, and could finally, clearly see exactly where that money had actually been going all along.',
    remember:
        'Untracked money is genuinely not saved by pure accident. It is simply spent by quiet, unnoticed default.',
    ledgrrSees:
        'Log any side income you receive in LEDGRR under its own distinct category, kept clearly separate from your regular primary income.',
  ),
  FinanceLesson(
    id: 'new_side_income_own_home',
    level: 'Clarity',
    title: 'Giving your side income its own home',
    hook: 'Money without a category becomes money without a purpose.',
    explanation:
        'Side income that is deliberately given its own dedicated tracking category is genuinely far easier to plan realistically around, calculate taxes correctly on, and eventually direct purposefully toward specific goals, compared to income that simply gets mixed in indistinguishably with everything else you earn.\n\nThe small upfront effort of separating this income properly from the very beginning pays off substantially later, particularly at moments like tax season or when applying for any kind of loan.',
    realLife:
        'Ayaan began logging his freelance income entirely separately from day one, which made both tax season and his regular monthly budgeting dramatically simpler compared to the previous year, when everything had been mixed together indistinguishably.',
    remember:
        'Give any irregular income its own dedicated home right from the very first payment, not after an entire year of mixing it in.',
    ledgrrSees:
        'Create a dedicated side-income category inside LEDGRR and consistently log every single payment specifically there, separate from everything else.',
  ),
  FinanceLesson(
    id: 'new_extra_money_real_budget',
    level: 'Clarity',
    title: 'What "extra money" actually means for your real budget',
    hook: '"Extra" money is still real money. Your budget should know it exists.',
    explanation:
        'Mentally treating side income as somehow entirely separate from your "real" primary income often means that money never actually gets properly factored into an honest, complete picture of your total available financial resources, even though it is genuinely real, spendable money either way.\n\nThe label "extra" tends to psychologically excuse that income from serious budgeting consideration, even when it represents a genuinely significant and reliable portion of overall monthly resources.',
    realLife:
        'Priyanka eventually realized that her regular side tutoring income, once properly and honestly counted alongside everything else, meant her real total monthly income was significantly higher than what she had been mentally budgeting around for months.',
    remember:
        'If the money is genuinely real and spendable, your budget should honestly count it as real too, not as a separate bonus.',
    ledgrrSees:
        'Make sure logged side income is properly included in LEDGRR\'s Monthly Summary total, not treated separately from your primary income figure.',
  ),
  FinanceLesson(
    id: 'new_panic_save_pattern',
    level: 'Clarity',
    title: 'The panic-save pattern — and why it barely works',
    hook: 'Saving under panic rarely saves enough, and it never feels good.',
    explanation:
        'Waiting until a savings deadline is genuinely nearly upon you before starting to save in earnest means compressing what should have been months of steady saving into just a handful of stressful, rushed days, which is both genuinely uncomfortable and usually mathematically insufficient to actually reach the intended goal amount in time.\n\nThe math of a goal does not actually care how motivated or panicked someone feels close to the deadline — it only cares whether enough total time and enough total money were realistically available across the whole period.',
    realLife:
        'Yash attempted to save his entire trip fund amount within the final week before his deadline and fell dramatically, noticeably short, despite that exact same total amount being genuinely, easily achievable if spread out evenly across the several months that had actually been available beforehand.',
    remember:
        'A last-minute panic-save at the deadline almost never actually matches what steady, early saving would genuinely have achieved.',
    ledgrrSees:
        'Set your Event Wallet goal inside LEDGRR the very same day you first learn the actual deadline date, not during the final week beforehand.',
  ),
  FinanceLesson(
    id: 'new_starting_before_ready',
    level: 'Clarity',
    title: 'Starting before you feel ready',
    hook: 'Waiting to feel ready to save is how most saving never starts.',
    explanation:
        'The feeling of being genuinely, fully prepared and ready to start saving very rarely simply arrives on its own accord, no matter how long someone waits for it. Starting with a small, admittedly imperfect amount right now genuinely beats continuing to wait indefinitely for some imagined "better" future moment that keeps quietly getting pushed further back.\n\nReadiness is very often a feeling that only actually shows up after starting, not reliably before it, which is exactly why waiting for it first tends to delay things indefinitely.',
    realLife:
        'Simran kept waiting patiently for a genuinely "better time" to start saving toward her specific goal, and only actually started once she finally gave up on that waiting entirely and simply began immediately with a small, imperfect amount instead.',
    remember:
        'The right time to actually start saving is very rarely a feeling that arrives on its own. It is simply a decision you make.',
    ledgrrSees:
        'Open LEDGRR right now and start an Event Wallet today, even if it begins with a genuinely small first deposit.',
  ),
  FinanceLesson(
    id: 'new_procrastination_cost_rupees',
    level: 'Clarity',
    title: 'What procrastination actually costs, in rupees',
    hook: 'Delay isn\'t free. It just hides its price until later.',
    explanation:
        'Delaying the start of saving toward any specific goal means the exact same total target amount must now be compressed into fewer remaining days, which mathematically requires noticeably larger, harder weekly or monthly amounts later on — a genuine, real cost of waiting that is very easy to significantly underestimate at the time the delay actually happens.\n\nThe total goal amount never actually shrinks simply because you started later. Only the available time to reach it does, which directly increases the required pace.',
    realLife:
        'Karan calculated precisely that starting his specific savings goal just one month later than planned meant he would need to save nearly double the amount per week for the remaining available time — a genuinely real cost he had not properly considered before choosing to delay.',
    remember:
        'Delaying a savings goal does not actually remove its underlying cost. It simply concentrates that same cost into less remaining time.',
    ledgrrSees:
        'Check how your required daily saving amount visibly changes inside LEDGRR\'s Event Wallet as an approaching deadline draws genuinely closer.',
  ),
  FinanceLesson(
    id: 'new_ill_save_later_to_now',
    level: 'Clarity',
    title: 'Turning "I\'ll save later" into "I\'m saving now"',
    hook: '"Later" is a plan with no actual date attached.',
    explanation:
        'The phrase "I will save later" almost never actually converts into a genuine, real action, precisely because "later" has no specific, concrete trigger attached to it that would ever actually prompt the behavior to begin. Naming today\'s exact, specific date as the genuine start removes all of that lingering ambiguity that otherwise lets procrastination continue quietly, indefinitely.\n\nA vague future intention and a concrete, dated commitment are psychologically very different things, even when the underlying goal itself is identical.',
    realLife:
        'Divya had been telling herself "I will start saving soon" for several months running, until she finally simply committed to genuinely starting on one specific, named day, rather than continuing to reference some vague, undefined point in the future.',
    remember:
        '"Later" is genuinely not a real plan on its own. A specific, named date actually is.',
    ledgrrSees:
        'Start your LEDGRR savings goal today, using today\'s actual real date as the genuine start, rather than some vague future placeholder.',
  ),
    FinanceLesson(
    id: 'new_beat_own_deadline',
    level: 'Clarity',
    title: 'Beating your own deadline on purpose',
    hook: 'Setting an earlier personal deadline builds in room for real life to happen.',
    explanation:
        'Deliberately targeting completion a week or two ahead of the actual real deadline creates a genuine, real buffer for unexpected disruptions along the way, so that one single bad week does not end up derailing the entire goal at the very last moment.\n\nReal life rarely proceeds in a perfectly straight line, and a savings plan with zero built-in slack is genuinely fragile against even one ordinary, unremarkable disruption.',
    realLife:
        'Farhan deliberately set his own personal savings deadline five full days earlier than the actual real one, which meant that an unexpected mid-month expense did not genuinely threaten his overall goal at all, since the buffer absorbed it comfortably.',
    remember:
        'A buffer built in on purpose is genuinely far better than a crisis discovered entirely by accident.',
    ledgrrSees:
        'Set your LEDGRR Event Wallet target date a few days earlier than the actual real deadline, deliberately building in a genuine buffer.',
  ),
  FinanceLesson(
    id: 'new_consistency_over_intensity',
    level: 'Clarity',
    title: 'Why consistency beats intensity in saving',
    hook: 'A small amount every month beats a large amount some months.',
    explanation:
        'Irregular, intense bursts of saving are genuinely harder to sustain over time and far easier to abandon partway through, compared to smaller, admittedly more boring, consistent contributions that quietly compound over time regardless of any single month\'s motivation levels.\n\nConsistency wins primarily because it does not actually depend on feeling motivated in any particular week — it simply continues running in the background either way.',
    realLife:
        'Ananya\'s occasional large, irregular deposits added up to noticeably less over a full year than a friend\'s smaller but perfectly consistent monthly amount, despite Ananya\'s total personal effort genuinely feeling larger throughout the year.',
    remember:
        'Consistency genuinely compounds over time. Intensity tends to burn out fairly quickly.',
    ledgrrSees:
        'Compare your LEDGRR jar deposit dates for any noticeable gaps, and aim instead for smaller, regular deposits rather than occasional large, irregular ones.',
  ),
  FinanceLesson(
    id: 'new_two_week_rule',
    level: 'Clarity',
    title: 'The two-week rule — bridging the gap between burst deposits',
    hook: 'If two weeks pass with no deposit, that\'s the signal to act, not wait for motivation.',
    explanation:
        'Setting yourself a personal rule that no more than two weeks should genuinely pass between successive jar deposits keeps naturally irregular, burst-style saving from quietly turning into long, entirely unpredictable gaps with no deposits at all for extended stretches.\n\nA simple time-based rule like this catches a developing gap early, before it has a chance to become an entire missed month or longer.',
    realLife:
        'Rohit noticed that his own jar deposits sometimes had genuine gaps of well over a month between them, and setting himself a strict personal two-week rule closed that specific gap significantly going forward.',
    remember:
        'A rule that reliably catches gaps early is genuinely more dependable than simply waiting to feel motivated again on your own.',
    ledgrrSees:
        'Check the actual dates of your last few LEDGRR jar deposits — if it has genuinely been over two weeks, treat that as your specific cue to act.',
  ),
  FinanceLesson(
    id: 'new_burst_to_standing_order',
    level: 'Clarity',
    title: 'Turning burst motivation into a standing order',
    hook: 'Motivation is unreliable. A standing order isn\'t.',
    explanation:
        'Sprinter-style saving genuinely relies on a fresh burst of motivation showing up again and again over time, which is an inherently fragile system to depend on long-term. Setting up an automatic, recurring transfer instead converts that unreliable motivation into a purely mechanical habit that continues running whether or not you actually feel like saving in any given week.\n\nThe entire point of automation here is removing the requirement for ongoing willpower or motivation from the equation altogether, replacing it with a system that simply runs on its own regardless.',
    realLife:
        'Ishaan used to save in large, genuinely irregular bursts whenever he happened to feel especially motivated, then would go completely silent for weeks at a time afterward. Setting up a small, automatic weekly transfer meant saving kept happening consistently even during his least motivated stretches.',
    remember:
        'Do not rely on remembering to save on your own. Build a system where it genuinely happens automatically, without you.',
    ledgrrSees:
        'Set a recurring reminder or standing transfer for the same day your allowance lands, so a LEDGRR jar deposit happens automatically, before spending gets first claim on the money.',
  ),
  FinanceLesson(
    id: 'new_one_goal_trap',
    level: 'Clarity',
    title: 'The one-goal trap — why single-focus savers stall after success',
    hook: 'Hitting your one goal is a win. Having nothing after it is the trap.',
    explanation:
        'Focusing intensely on a single savings goal genuinely works well right up until the moment it is actually achieved, at which point the entire underlying saving habit can vanish essentially overnight, with absolutely nothing lined up to redirect that same momentum toward afterward.\n\nThe genuine skill being built here is not really "achieving this one particular goal" — it is actually "the ongoing habit of saving itself," and stopping entirely right after one success suggests that deeper skill was never fully separated from the specific target in the first place.',
    realLife:
        'Farhan fully funded his laptop savings goal and then had genuinely no active saving habit at all for the following two months afterward, with nothing meaningful to show for the strong momentum he had clearly built up beforehand.',
    remember:
        'A finished savings goal is genuinely a launchpad for the next one, not a finish line to stop entirely at.',
    ledgrrSees:
        'The moment a Jar or Event Wallet hits 100% inside LEDGRR, open it again immediately and start planning the very next one.',
  ),
  FinanceLesson(
    id: 'new_second_habit_before_needed',
    level: 'Clarity',
    title: 'Building a second habit before you need one',
    hook: 'Decide your next goal before the current one finishes, not after.',
    explanation:
        'Naming even a rough, tentative next goal while your current one is still genuinely in progress removes the awkward, empty gap where motivation would otherwise have nowhere left to go once that first goal actually completes successfully.\n\nThis is essentially a small piece of forward planning that costs almost nothing in the present moment, while genuinely protecting your future momentum from stalling out entirely once the current goal wraps up.',
    realLife:
        'Ishita named a genuinely rough, unfinished next goal for herself while still actively funding her first one, which meant there was no empty, aimless gap at all once that first goal was actually reached successfully.',
    remember:
        'Line up your next savings goal before the current one actually ends, not sometime afterward once the momentum has already faded.',
    ledgrrSees:
        'While actively funding a current LEDGRR goal, take a moment to jot down what your genuine next one might realistically be.',
  ),
  FinanceLesson(
    id: 'new_ill_think_later_rarely_happens',
    level: 'Clarity',
    title: 'Why "I\'ll think of the next goal later" rarely happens',
    hook: 'Later, without a plan, usually means never.',
    explanation:
        'Deliberately deferring the decision of choosing a next goal to some vague "later" almost always genuinely means that decision simply never actually gets made at all, precisely because there is no specific trigger or moment ever prompting the actual decision to finally happen.\n\nThis pattern mirrors the earlier lesson about "I will save later" — the underlying issue is always the same lack of a concrete, specific trigger attached to the vague future intention.',
    realLife:
        'Om told himself he would genuinely think of a new savings goal "later" once his current one finished, and a full six months quietly passed afterward with no new goal chosen and effectively no active saving habit remaining at all.',
    remember:
        '"Later" genuinely needs a specific, concrete trigger attached to it, or it simply, quietly becomes never.',
    ledgrrSees:
        'Set the trigger for yourself directly: decide your genuine next LEDGRR goal on the exact same day your current one actually completes.',
  ),
  FinanceLesson(
    id: 'new_diversify_saving',
    level: 'Clarity',
    title: 'Diversifying your saving, not just your goals',
    hook: 'One goal at a time is fine. One habit at a time is the real risk.',
    explanation:
        'The actual underlying habit of saving itself genuinely matters more in the long run than any single specific goal attached to it at any given moment. Deliberately building and protecting the broader habit, rather than exclusively chasing one particular target, means that habit genuinely survives intact even well after that specific target has already been reached.\n\nThinking of yourself as "someone who saves regularly" is a fundamentally more durable identity than thinking of yourself purely as "someone saving for this one specific thing."',
    realLife:
        'Kavya eventually realized her genuine underlying strength was never really the laptop goal itself specifically — it was actually the broader habit of regular saving, which she then deliberately and consciously kept going afterward, redirected toward an entirely different target.',
    remember:
        'You are genuinely not just saving for one specific thing at a time. You are actively building the broader habit of saving itself.',
    ledgrrSees:
        'Keep at least one active goal open inside LEDGRR at all times, so the underlying saving habit itself genuinely never lapses entirely.',
  ),
  FinanceLesson(
    id: 'new_onetime_to_habitual',
    level: 'Clarity',
    title: 'From one-time saver to habitual saver',
    hook: 'The shift from saving once to saving always is the real upgrade.',
    explanation:
        'Successfully funding one single savings goal genuinely proves that the underlying mechanics of your saving approach actually work in practice. The genuine next step forward is treating saving itself as an ongoing personal identity, rather than continuing to treat it as a one-time project tied narrowly to just a single target.\n\nThis shift in framing — from "I completed a savings project" to "I am someone who saves" — tends to be the real, lasting difference between people who save consistently for years and people who save successfully just once.',
    realLife:
        'After successfully funding his emergency fund, Vikram made a genuinely conscious, deliberate decision to keep saving as an ongoing habit going forward, rather than treating that specific project as fully "done" and complete.',
    remember:
        'One completed savings goal genuinely proves you can save. The ongoing habit is what actually makes it last for years.',
    ledgrrSees:
        'After completing any LEDGRR goal, immediately start funding a new one, however genuinely small, specifically to keep the underlying habit alive.',
  ),
  FinanceLesson(
    id: 'new_gap_between_goals',
    level: 'Clarity',
    title: 'What happens to your money in the gap between goals',
    hook: 'The days between one goal ending and the next starting are the riskiest days.',
    explanation:
        'Money that would previously have gone toward an active savings goal, once that specific goal is actually complete, very often simply gets quietly absorbed back into ordinary regular spending during the empty gap before any new goal has actually been chosen and set.\n\nThis particular gap period is genuinely one of the highest-risk moments for an otherwise healthy saving habit, precisely because there is no active target currently pulling that money in any specific direction.',
    realLife:
        'Farhan\'s newly "extra" money quietly disappeared back into his regular, undirected spending during the roughly two months between finishing one savings goal and eventually starting his next one.',
    remember:
        'The empty gap between one goal ending and the next one starting is exactly when your saving money is most genuinely at risk of quietly vanishing.',
    ledgrrSees:
        'Minimize this gap inside LEDGRR by starting your next Jar or Event Wallet on the exact same day your previous one actually completes.',
  ),
    FinanceLesson(
    id: 'new_prioritizing_goals',
    level: 'Mastery',
    title: 'Prioritizing goals when you can\'t fund them all at once',
    hook: 'Funding five goals a little each often means funding none of them well.',
    explanation:
        'When multiple genuine savings goals are competing for the exact same limited pool of available money, ranking them honestly by real priority and then funding the top ones first usually beats spreading thin, roughly equal contributions evenly across all of them simultaneously.\n\nSpreading resources too thin across many goals at once often means every single one progresses so slowly that none of them ever actually feels close to completion, which quietly drains motivation across the board rather than protecting it.',
    realLife:
        'Ananya had been splitting small amounts across four separate goals at once and was genuinely making slow, barely visible progress on all of them, until she deliberately ranked them by real priority and focused most of her saving specifically on the top two first.',
    remember:
        'Spreading your saving too thin often genuinely means finishing nothing at all. Ranking honestly usually finishes something real.',
    ledgrrSees:
        'Review your active LEDGRR Jars and Events honestly, and decide which one genuinely matters most to fund right now.',
  ),
  FinanceLesson(
    id: 'new_spreading_too_thin',
    level: 'Mastery',
    title: 'The danger of spreading yourself across too many goals',
    hook: 'Five half-funded goals feel like progress. They usually aren\'t.',
    explanation:
        'Having many simultaneous active goals can genuinely feel productive and ambitious in the moment, but if none of them are actually getting meaningfully close to completion, the real psychological reward of finishing anything at all keeps getting pushed further and further back indefinitely.\n\nThe feeling of "working on many things" is not the same as the feeling of "actually finishing things," and only the second one genuinely reinforces a lasting saving habit over time.',
    realLife:
        'Kabir had six separate active goals running simultaneously, all sitting at roughly 20% funded, and eventually realized he genuinely had not actually completed a single one of them in several months.',
    remember:
        'Completing one single goal genuinely beats partially funding six goals at once.',
    ledgrrSees:
        'Check honestly how many active, unfinished Jars and Events you currently have open inside LEDGRR right now.',
  ),
  FinanceLesson(
    id: 'new_sequencing_goals',
    level: 'Mastery',
    title: 'Sequencing goals — what to fund first and why',
    hook: 'The order you fund goals in matters as much as the goals themselves.',
    explanation:
        'A genuinely sensible sequence for funding multiple goals usually funds urgent, safety-related goals first — like a proper emergency fund — before moving on to more lifestyle-oriented goals such as trips or gadgets, since that underlying safety net genuinely protects everything funded after it from being wiped out by an unexpected setback.\n\nFunding a fun, lifestyle goal before a genuine safety net exists means any unexpected emergency will likely force you to raid that fun goal anyway, effectively undoing the progress and adding real stress on top of it.',
    realLife:
        'Rohan deliberately reordered his personal goals to fund his emergency fund before his trip fund, reasoning correctly that an unexpected expense would otherwise have forced him to raid the trip fund regardless, undoing that progress entirely.',
    remember:
        'Fund genuine safety goals before lifestyle goals, so that an emergency does not quietly undo your other progress elsewhere.',
    ledgrrSees:
        'Honestly consider which specific LEDGRR goal genuinely needs to be funded first for real, meaningful financial safety.',
  ),
  FinanceLesson(
    id: 'new_consolidate_goals',
    level: 'Mastery',
    title: 'When to consolidate goals instead of adding new ones',
    hook: 'Sometimes the answer isn\'t a new goal, it\'s fewer, bigger ones.',
    explanation:
        'Having too many small, genuinely overlapping goals running at once can often be simplified considerably by consolidating similar ones into a single, larger, clearer target, which reduces overall complexity without actually reducing any real underlying progress.\n\nMore separate goals is not automatically better organization — past a certain point, it simply becomes more clutter to mentally track, without adding any genuine additional clarity or benefit.',
    realLife:
        'Meera had three separate, genuinely small "gadget" goals running that were really, underneath everything, the same underlying desire split apart unnecessarily, and consolidating them into one single, clearer goal made her overall tracking dramatically simpler.',
    remember:
        'More goals is not automatically better organization. Sometimes it is genuinely just more clutter to manage.',
    ledgrrSees:
        'Review your existing LEDGRR goals honestly for any genuine overlap that could reasonably be merged into one clearer target.',
  ),
  FinanceLesson(
    id: 'new_boring_investing',
    level: 'Mastery',
    title: 'Why boring investing beats exciting investing',
    hook: 'The best investors in the world are the ones you\'ve never heard of.',
    explanation:
        'People who deliberately pick a reasonable, low-cost investment and then genuinely leave it alone for many years or decades consistently, statistically outperform people who actively chase excitement in their investing, since chasing excitement typically means buying in after a rally has already happened and selling in a panic after a crash has already occurred.\n\nGenuinely successful long-term investing tends to feel almost boring on a day-to-day basis, precisely because the real strategy is simply to keep doing the same steady thing consistently, without any dramatic changes along the way.',
    realLife:
        'Aakash actively chased "hot" individual stocks for roughly two years and genuinely underperformed a friend who had simply put the exact same total amount into one plain index fund and left it completely alone the entire time.',
    remember:
        'If your investing feels genuinely exciting on a regular basis, you are very likely doing it wrong somewhere.',
    ledgrrSees:
        'If you are already showing as a Steady Saver inside LEDGRR, deliberately protect that hard-won consistency from the tempting urge to chase something more exciting.',
  ),
  FinanceLesson(
    id: 'new_stepup_sip',
    level: 'Mastery',
    title: 'The step-up SIP — increasing your amount as your income grows',
    hook: 'The SIP you started at 20 shouldn\'t be the same size at 25.',
    explanation:
        'A step-up SIP means deliberately, consciously increasing your monthly investment amount every single time your overall income genuinely rises, so that your investing consistently grows in proportion to your actual life circumstances instead of quietly shrinking in relative importance over time as your income grows around it.\n\nKeeping a SIP amount perfectly flat for years, even as income rises substantially, effectively means investing represents a steadily shrinking share of your overall financial life, even though the absolute number on paper never technically changes.',
    realLife:
        'Divya kept her SIP contribution amount completely flat for three full years despite her actual income roughly tripling over that same period. Deliberately stepping it up alongside each raise kept her investing genuinely proportional to her real growth as it happened.',
    remember:
        'Every single time your income genuinely increases, deliberately ask yourself whether your SIP amount needs to increase alongside it.',
    ledgrrSees:
        'Compare your monthly income trend inside LEDGRR Statistics against your savings category over time — if one is rising while the other stays completely flat, that mismatch is your genuine signal to act.',
  ),
  FinanceLesson(
    id: 'new_break_restrict_splurge',
    level: 'Clarity',
    title: 'Breaking the restrict-then-splurge cycle',
    hook: 'Extreme restriction and extreme spending are the same habit wearing two different outfits.',
    explanation:
        'A genuinely common pattern of heavy, unrestrained spending followed by guilt-driven, extremely strict saving, which then eventually leads to burnout and a return to heavy spending again, is actually one single unstable cycle rather than two separate, unrelated problems. The real, lasting fix is finding a genuinely sustainable middle ground, rather than continuing to swing repeatedly between these two extremes.\n\nBoth extremes in this cycle are ultimately driven by the same underlying instability — neither one is genuinely more "disciplined" than the other, despite how the restrictive phase might feel in the moment.',
    realLife:
        'Tanya\'s repeating three-week-save, one-week-splurge cycle genuinely stopped only once she deliberately built herself a moderate, realistically sustainable weekly budget, replacing the extreme, all-or-nothing monthly approach she had been using before.',
    remember:
        'A budget you genuinely cannot sustain is not actually discipline — it is simply delayed spending with extra guilt attached on top.',
    ledgrrSees:
        'Look for a genuine sawtooth pattern in your LEDGRR monthly totals — high, low, high, low — since that specific shape is exactly this unstable cycle showing up clearly in your own real data.',
  ),
  FinanceLesson(
    id: 'new_why_extreme_budgets_break',
    level: 'Clarity',
    title: 'Why extreme budgets always break',
    hook: 'A budget with no room to breathe eventually gets abandoned entirely.',
    explanation:
        'Budgets that genuinely demand near-total restriction with essentially zero flexibility very rarely survive real life\'s ordinary, small unplanned moments intact, and breaking just one single rule within such a rigid budget very often leads directly to abandoning the entire plan altogether, rather than simply adjusting it slightly and continuing forward.\n\nA rigid, all-or-nothing structure genuinely offers no reasonable path back once even a small mistake happens, which makes total abandonment feel like the only remaining option in the moment.',
    realLife:
        'Ibrahim set himself a genuinely extremely tight budget that broke down completely on just day four, and rather than simply adjusting it slightly and continuing on, he ended up abandoning budgeting entirely for the remainder of that specific month.',
    remember:
        'A realistic budget you can genuinely actually follow beats a theoretically perfect one that you end up abandoning within a week.',
    ledgrrSees:
        'If your LEDGRR spending consistently blows straight past a self-imposed limit almost immediately every time, the limit itself may genuinely be unrealistic rather than your discipline being the actual problem.',
  ),
  FinanceLesson(
    id: 'new_sawtooth_pattern',
    level: 'Clarity',
    title: 'The sawtooth pattern — spotting your own cycle',
    hook: 'Your own Statistics chart can show you a cycle you didn\'t know you had.',
    explanation:
        'A genuinely visible high-low-high-low pattern appearing across several consecutive months of spending or saving totals is the direct, honest fingerprint of an unstable restrict-and-splurge cycle, and it is genuinely worth explicitly naming once you actually notice it clearly laid out in your own real data.\n\nMany people experience this exact cycle for months or even years without ever consciously recognizing it as a repeating pattern, simply because they never actually looked at several months\' totals laid out side by side at once.',
    realLife:
        'Tanya only genuinely recognized her own repeating cycle once she deliberately looked at several months of her own totals laid out directly side by side, and finally saw the unmistakable zigzag shape that had been quietly forming the entire time.',
    remember:
        'A pattern you can genuinely see clearly is a pattern you can finally, actually address directly.',
    ledgrrSees:
        'Compare several consecutive months of totals inside LEDGRR Statistics side by side to check honestly for this specific zigzag shape appearing.',
  ),
  FinanceLesson(
    id: 'new_sustainable_beats_aggressive',
    level: 'Clarity',
    title: 'Sustainable beats aggressive, every time',
    hook: 'The plan that survives contact with real life wins, even if it looks less impressive on paper.',
    explanation:
        'An aggressive, ambitious plan that genuinely fails and collapses partway through ultimately delivers noticeably less real progress than a more modest plan that is actually followed through consistently for the entire intended period.\n\nA plan\'s theoretical maximum potential on paper genuinely means very little if it never actually survives long enough in practice to be completed as originally intended.',
    realLife:
        'Sana\'s genuinely "aggressive" savings plan collapsed entirely by roughly week two, while a friend\'s noticeably more modest but perfectly consistent plan ultimately ended up saving more overall across the exact same total number of months.',
    remember:
        'A plan you will genuinely actually finish beats a theoretically better plan that you end up abandoning halfway through.',
    ledgrrSees:
        'Set your LEDGRR goals sized specifically to what you can genuinely, realistically sustain over time, not simply to whatever sounds most impressive on paper.',
  ),
  FinanceLesson(
    id: 'new_guilt_not_strategy',
    level: 'Clarity',
    title: 'Guilt is not a financial strategy',
    hook: 'Feeling bad about a spend doesn\'t undo it, and it rarely prevents the next one either.',
    explanation:
        'Feeling genuine guilt after overspending very often directly triggers the extremely restrictive half of the unstable cycle, rather than actually leading to any genuinely useful, calm decision, which ends up perpetuating exactly the same unstable pattern rather than actually breaking it for good.\n\nGuilt is an emotional reaction, not an actual plan, and mistaking one for the other tends to keep the entire underlying cycle running indefinitely rather than resolving it.',
    realLife:
        'Rajat noticed clearly that his own genuine guilt after overspending always led him directly straight into an extreme restrictive phase afterward, rather than leading to any calm, genuinely useful adjustment to his ongoing approach.',
    remember:
        'Replace guilt with one specific, calm adjustment instead. Guilt on its own genuinely changes absolutely nothing by itself.',
    ledgrrSees:
        'After logging an overspend inside LEDGRR, deliberately decide on one specific, concrete adjustment instead of simply feeling bad about it and moving on.',
  ),
  FinanceLesson(
    id: 'new_budget_you_wont_rebel_against',
    level: 'Clarity',
    title: 'Setting a budget you won\'t want to rebel against',
    hook: 'A budget that feels like punishment invites rebellion. A fair one doesn\'t.',
    explanation:
        'A budget that genuinely includes reasonable, deliberate room for fun and flexibility is far less likely to trigger the strong urge to abandon it entirely, compared to one that feels purely restrictive and punishing from the very start with no room to breathe.\n\nBuilding in a modest, honest allowance for enjoyment is not a weakness in a budget — it is genuinely what makes that same budget realistic enough to actually survive contact with an ordinary, real life over the long term.',
    realLife:
        'Farah\'s new, redesigned budget deliberately included a reasonable "fun" allowance built directly into it, and she found she genuinely no longer felt the same strong urge to abandon it entirely, unlike her previous, stricter budget which had repeatedly triggered exactly that reaction.',
    remember:
        'A budget with genuine room to breathe is a budget you will actually, realistically keep following over time.',
    ledgrrSees:
        'Build a realistic "fun" category directly into your LEDGRR budget, rather than attempting to eliminate that kind of spending entirely.',
  ),
];
// Looks up a lesson by ID, skipping quietly if it doesn't exist,
// instead of crashing. Protects against any future mismatch between
// an archetype's recommended lessonIds and this lesson list.
List<FinanceLesson> _lessonsById(List<String> ids) {
  final result = <FinanceLesson>[];
  for (final id in ids) {
    final matches = _allLessons.where((l) => l.id == id);
    if (matches.isNotEmpty) result.add(matches.first);
  }
  return result;
}

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
  final _archetypeService = SpenderArchetypeService();
  ArchetypeResult? _archetype;
  bool _isLoading = true;
  final List<String> _levels = ['Foundation', 'Clarity', 'Mastery'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProgress();
    _loadArchetype();
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

  Future<void> _loadArchetype() async {
    final result = await _archetypeService.computeArchetype();
    if (mounted) setState(() => _archetype = result);
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
    final recommended =
        _archetype != null ? _lessonsById(_archetype!.lessonIds) : <FinanceLesson>[];

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
            // Personalized archetype banner
            if (_archetype != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.isDark ? palette.bg2 : palette.ink,
                    borderRadius: BorderRadius.circular(18),
                    border: palette.isDark
                        ? Border.all(color: palette.border)
                        : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: palette.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.auto_awesome_rounded,
                            color: palette.accent, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('This month, you\'re',
                                style: GoogleFonts.syne(
                                    fontSize: 10,
                                    color: palette.isDark
                                        ? palette.inkMuted
                                        : Colors.white54)),
                            const SizedBox(height: 2),
                            Text(_archetype!.name,
                                style: GoogleFonts.syne(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: palette.isDark
                                        ? palette.ink
                                        : Colors.white)),
                            const SizedBox(height: 6),
                            Text(_archetype!.tagline,
                                style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 12.5,
                                    fontStyle: FontStyle.italic,
                                    color: palette.isDark
                                        ? palette.inkMuted
                                        : Colors.white70,
                                    height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Recommended for you
            if (recommended.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recommended for you',
                        style: GoogleFonts.syne(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: palette.ink)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 118,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recommended.length,
                        itemBuilder: (context, i) {
                          final lesson = recommended[i];
                          final isRead = _readLessons.contains(lesson.id);
                          return Padding(
                            padding: EdgeInsets.only(
                                right: i < recommended.length - 1 ? 10 : 0),
                            child: GestureDetector(
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
                                width: 210,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: palette.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isRead
                                        ? palette.accent.withOpacity(0.3)
                                        : palette.border,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: palette.accent
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: Text(lesson.level,
                                              style: GoogleFonts.syne(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color: palette.accent)),
                                        ),
                                        if (isRead) ...[
                                          const Spacer(),
                                          Icon(Icons.check_circle_rounded,
                                              size: 14, color: palette.accent),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Text(lesson.title,
                                          style: GoogleFonts.syne(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: palette.ink,
                                              height: 1.35),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
                    if (lesson.resources.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _sectionLabel('Go deeper', palette),
                      const SizedBox(height: 10),
                      ...lesson.resources.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: palette.bg2,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: palette.border),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.menu_book_rounded,
                                      color: palette.inkMuted, size: 16),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(r.title,
                                            style: GoogleFonts.syne(
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w700,
                                                color: palette.ink)),
                                        Text(r.author,
                                            style: GoogleFonts.syne(
                                                fontSize: 11,
                                                color: palette.inkMuted)),
                                        const SizedBox(height: 4),
                                        Text(r.note,
                                            style: GoogleFonts.syne(
                                                fontSize: 12,
                                                color: palette.inkMuted,
                                                height: 1.5)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                    const SizedBox(height: 32),
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