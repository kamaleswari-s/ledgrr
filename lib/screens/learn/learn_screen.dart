import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';

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

  // ── FOUNDATION — NEW ────────────────────────────────────────────────────
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