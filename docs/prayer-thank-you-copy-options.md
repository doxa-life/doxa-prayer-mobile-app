# Prayer Thank-You Modal — Copy Options

Thirty alternative message + verse pairs for the modal shown after a user taps **Amen**
(`prayerThankYouMessage`, `prayerThankYouVerse`, `prayerThankYouVerseReference` — see
`lib/components/prayer_content/prayer_thank_you_modal.dart`).

Each pair is written so the message and the verse reinforce each other. Please add your
comments / picks inline.

## Currently shipping

> **Title:** Thank you for praying
> **Message:** Your faithfulness in prayer matters. God hears you, and your prayers make a difference.
> **Verse:** *"Rejoice always, pray continually, give thanks in all circumstances; for this is God's will for you in Christ Jesus."* — 1 Thessalonians 5:16-18

---

## A. "God hears you" — closest to the current

**6.**
**Message:** Your prayer rose today like incense — small, quiet, and precious to God.
**Verse:** *"May my prayer be set before you like incense; may the lifting up of my hands be like the evening sacrifice."* — Psalm 141:2

---

## B. Prayer that reaches the nations — fits the UUPG focus

**8.**
**Message:** You just prayed for people most of the world has never named. God knows every one of them.
**Verse:** *"All the nations you have made will come and worship before you, Lord; they will bring glory to your name."* — Psalm 86:9

**9.**
**Message:** You prayed today for a people group waiting to hear. That is exactly what God invites you to ask for.
**Verse:** *"Ask me, and I will make the nations your inheritance, the ends of the earth your possession."* — Psalm 2:8

**10.**
**Message:** The day is coming when this people group will stand in that crowd. You prayed them toward it.
**Verse:** *"After this I looked, and there before me was a great multitude that no one could count, from every nation, tribe, people and language, standing before the throne and before the Lamb."* — Revelation 7:9

**11.**
**Message:** You asked the Lord of the harvest for workers today. That prayer moves people across the world.
**Verse:** *"Ask the Lord of the harvest, therefore, to send out workers into his harvest field."* — Matthew 9:38

**12.**
**Message:** Your prayer joins God's oldest promise: that his blessing would reach every nation on earth.
**Verse:** *"May God be gracious to us and bless us and make his face shine on us — so that your ways may be known on earth, your salvation among all nations."* — Psalm 67:1-2

**13.**
**Message:** You prayed for a place where his glory is not yet known. One day it will be.
**Verse:** *"For the earth will be filled with the knowledge of the glory of the Lord as the waters cover the sea."* — Habakkuk 2:14

**14.**
**Message:** Someone has to hear before they can believe. Your prayer today is part of how they will.
**Verse:** *"And how can they believe in the one of whom they have not heard? And how can they hear without someone preaching to them?"* — Romans 10:14

**15.**
**Message:** You prayed for a door to open somewhere you may never go.
**Verse:** *"And pray for us, too, that God may open a door for our message."* — Colossians 4:3

**16.**
**Message:** God wants this people group found more than you do. Your prayer agrees with his heart.
**Verse:** *"[God] wants all people to be saved and to come to a knowledge of the truth."* — 1 Timothy 2:4

**17.**
**Message:** What feels like delay is patience. God is waiting for these people, too.
**Verse:** *"The Lord is not slow in keeping his promise, as some understand slowness. Instead he is patient with you, not wanting anyone to perish, but everyone to come to repentance."* — 2 Peter 3:9

**18.**
**Message:** The good news will reach every nation. You prayed for one of them today.
**Verse:** *"And this gospel of the kingdom will be preached in the whole world as a testimony to all nations, and then the end will come."* — Matthew 24:14

**19.**
**Message:** You prayed "your kingdom come" over a real place, with real names.
**Verse:** *"Your kingdom come, your will be done, on earth as it is in heaven."* — Matthew 6:10

**20.**
**Message:** You may not be the one who goes — but today you were the one who asked.
**Verse:** *"Then I heard the voice of the Lord saying, 'Whom shall I send? And who will go for us?' And I said, 'Here am I. Send me!'"* — Isaiah 6:8

---

## C. Keep going — for returning, habitual users

**23.**
**Message:** Prayer like this is a habit before it is a feeling. You built it a little more today.
**Verse:** *"Devote yourselves to prayer, being watchful and thankful."* — Colossians 4:2

**24.**
**Message:** Some prayers are planted now and gathered much later.
**Verse:** *"Those who sow with tears will reap with songs of joy."* — Psalm 126:5

**25.**
**Message:** You aren't praying alone. Believers around the world are asking the same thing today.
**Verse:** *"And pray in the Spirit on all occasions with all kinds of prayers and requests. With this in mind, be alert and always keep on praying for all the Lord's people."* — Ephesians 6:18

**26.**
**Message:** You made room today for people you'll likely never meet. That's what intercession is.
**Verse:** *"I urge, then, first of all, that petitions, prayers, intercession and thanksgiving be made for all people."* — 1 Timothy 2:1

---

## D. God does the work — takes the weight off the user

**27.**
**Message:** The outcome was never on your shoulders. You asked; God acts.
**Verse:** *"Not by might nor by power, but by my Spirit, says the Lord Almighty."* — Zechariah 4:6

**28.**
**Message:** Your words were small. The one who answers them is not.
**Verse:** *"So is my word that goes out from my mouth: It will not return to me empty, but will accomplish what I desire and achieve the purpose for which I sent it."* — Isaiah 55:11

**29.**
**Message:** Leave it with him now. What you carried in, you don't have to carry out.
**Verse:** *"Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God."* — Philippians 4:6

**30.**
**Message:** Prayer isn't the least you can do. It's how God chose to move.
**Verse:** *"The prayer of a righteous person is powerful and effective."* — James 5:16

---

## Open questions for the team

1. **Translation / licensing.** These are quoted in NIV wording to match the existing
   1 Thessalonians 5:16-18 string. If the app should use a public-domain translation
   (WEB, ASV) or we hold a specific licence, we need to decide before shipping — and every
   verse should be checked word-for-word against the chosen translation.

2. **One message, or a rotating set?** The l10n keys are currently single strings. Rotating
   several variants (random per session, or cycling) means numbered keys
   (`prayerThankYouMessage1..N`) plus a picker, and each variant multiplies translation work
   across all six locales (en, es, fr, pt, ru, ar).

3. **Tone.** Section A is nearest to what ships today. B leans hardest into the unreached
   people group focus. C is aimed at repeat users. D deliberately lowers the pressure on the
   user. Which sections do we want represented?
