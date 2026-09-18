# Doxa App — Full Testing Guide

Thank you for helping us test the whole app! This guide walks through **every
main part** of Doxa, from first opening it to praying, setting reminders,
changing languages, and managing your account. It also includes the feedback,
email-verification, news-signup, profile and **accessibility** tests.

You don't need any technical knowledge — just follow the steps and tick the
boxes. If anything looks wrong, confusing, or different from what's described,
make a note.

## How to use this guide

- Work through the sections roughly in order (the later ones assume you've
  finished setup).
- Each item is a checkbox — tick ✅ if it works as described.
- If something is broken or confusing, note: **what you did**, **what you
  expected**, **what actually happened**, and a **screenshot** if possible.
- Use a **real email address you can open**, and ideally a phone where you can
  receive notifications.

> 💡 The app has a built-in **Feedback** button (Section 11) that automatically
> includes your phone details — a great way to send us notes as you go.

---

## ⭐ Priority tests

These are the most important things to confirm. Each is covered in full below —
please pay extra attention to them:

1. **Reminders work correctly** — a reminder you set actually alerts you at the
   right time on the right days → **Section 6**
2. **The Pray tab shows your chosen people group and today's prayers** →
   **Section 4**
3. **Installing from a shared QR/link auto-selects the right people group**
   (even when the app wasn't installed yet) → **Section 5**
4. **You can view a people group's information** → **Section 5**

---

## Section 1 — First-time setup (onboarding)

*Best done on a fresh install, or after clearing the app's data, so you see the
welcome flow.*

- [ ] On first launch, a **welcome screen** appears with the Doxa logo and a
      **Get started** button.
- [ ] Tapping **Get started** moves you to choosing a **people group**.
- [ ] You can **search** and **browse** the list of people groups.
- [ ] Selecting a group shows its **details**, and a **Select** button confirms it.
- [ ] After confirming, you're asked to **set a prayer reminder** — you can pick
      a **time** and **days of the week**, or tap **Skip**.
- [ ] Next you're invited to **sign up for updates** (name + email — see Section 8).
- [ ] After finishing, you land on the app's **Home** screen.

---

## Section 2 — Getting around (navigation)

- [ ] A **bottom menu bar** shows tabs: **Home**, **Pray**, **People Groups**,
      **Reminders**.
- [ ] Tapping each tab switches screens, and the current tab is highlighted.
- [ ] A **settings (gear) icon** is reachable from the top of the screen.
- [ ] Using your phone's **back** gesture/button behaves sensibly (and on Home,
      only exits the app after pressing back twice).

---

## Section 3 — Home screen

- [ ] Home shows a **card for your chosen people group** (or a prompt to choose
      one if you haven't).
- [ ] There's a **Pray** button that takes you to the Pray tab.
- [ ] There's a **Share** option for your people group.
  - [ ] Sharing offers a **link** to open the app / prayer page.
  - [ ] There's also an option to show a **QR code** someone nearby can scan.
- [ ] A **reminders summary** shows your upcoming prayer reminder(s).
- [ ] If you've selected a group but **haven't prayed yet today**, a banner appears at
      the **bottom** — *"Ready for today's prayer? Tap to pray for [your group]"*.
  - [ ] Tapping the banner opens the **Pray** tab.
  - [ ] Tapping its **×** dismisses it (it stays hidden for the rest of the session).
  - [ ] The banner **doesn't** appear once you've prayed today. (This is separate from
        the reminders summary above, which lists your scheduled reminder *times*.)
- [ ] After you've prayed today, the group card shows a green **"Prayed today"** badge.

---

## Section 4 — Praying (the Pray tab) ⭐

*This confirms the Pray tab shows **your** people group and **today's** prayers.*

**Steps:**
1. Choose a people group (Section 1 or 5) so you have one selected.
2. Tap the **Pray** tab.

**What you should see:**
- [ ] The Pray tab shows prayer content for **the people group you selected** —
      the name/details match your chosen group, **not** a different one.
- [ ] The content shown is for **today's date**.
- [ ] If you haven't chosen a group yet, it instead **prompts you to select one**.
- [ ] You can read the prayer content, scripture/verses and any images.
- [ ] Tapping a **credit** marker on an image shows the photo credit.
- [ ] The prayer content and the **Amen** button sit on a plain (white) area; **below**
      Amen, a **"My people group"** section and any copyright sit on a distinct
      shaded/beige band — making it clear where the prayer ends and the extra info begins.

**Day navigation:**
3. Tap the **previous-day** arrow, then the **next-day** arrow.

- [ ] You can move to **previous** days' prayers and back to today.
- [ ] You **cannot** go before the campaign's start or into the **future** (those
      arrows are greyed out).

**Amen:**
4. Tap **Amen**.

- [ ] A **thank-you message** appears, affirming your prayer (with a Bible verse).
- [ ] The modal has a **"Home"** button (house icon) that closes it and takes you to the
      **Home** tab. The **×** in the corner just closes the modal and leaves you on Pray.
- [ ] Afterwards the group shows as **prayed today** (e.g. on the Home card).

---

## Section 5 — People Groups (viewing info & selecting) ⭐

*This confirms you can view a people group's information and select one — and
that shared links/QRs bring you to the right group.*

### 5a. Browsing and viewing info

- [ ] The **People Groups** tab lists people groups you can pray for.
- [ ] The **search** box filters the list as you type, and can be cleared.
- [ ] Tapping a group opens its **details** page.
  - [ ] It shows **photos**, the group's **name**, a **description**, and an
        **engagement status** card.
  - [ ] The engagement card lists markers such as **Prayer status** and **Adoption
        status**, each with a coloured yes/no icon.
    - [ ] **Prayer status** has three states: **green** (prayer goal reached),
          **orange** (partial — some people praying but the goal isn't met yet), and
          **red** (no one praying yet).
    - [ ] For a group marked as **engaged**, the individual work markers collapse into a
          single green **"Engaged"** item (so you see fewer rows).
  - [ ] Everything reads correctly and nothing looks cut off.
- [ ] From details you can **Select** that group as your current one.
- [ ] Your **currently selected** group is clearly indicated in the list.

### 5b. Opening a shared link / QR when the app is already installed

**Steps:**
1. Get a **share link or QR code** for a people group (from the Home screen's
   Share option — Section 3 — on this or another phone).
2. With the app **already installed**, scan the QR / open the link.

**What you should see:**
- [ ] The app opens to **that specific people group** (its details, or the group
      pre-selected if you were still onboarding).

### 5c. **ANDROID ONLY** Installing from a QR / link auto-selects the group (deferred deep linking) ⭐

*This is the important one: a brand-new user scans a QR, installs the app, and
the app should already know which group they came for.* **(Android)**

**Steps:**
1. On a device that does **not** have Doxa installed, scan a people group's **QR
   code** (or open its share link, e.g. at https://doxa.pray.life/adi).
2. Follow it to the **Play Store** and **install** the app.
3. **Open** the app for the first time and go through setup.

**What you should see:**
- [ ] During onboarding, the people group **you scanned is already selected for
      you** — you don't have to search for it manually.
- [ ] That same group then shows on **Home** and in the **Pray** tab.

> 📱 **Note:** this automatic selection after a fresh install is an **Android**
> feature. On **iPhone/iOS**, scanning a link before installing may not carry the
> group through — that's expected. (Opening a link when the app is *already*
> installed works on both — see 5b.)

---

## Section 6 — Reminders ⭐

*This confirms reminders save correctly **and actually alert you**.*

### 6a. Creating and managing reminders

- [ ] The **Reminders** tab lists your prayer reminders (or an empty state if you
      have none).
- [ ] You can **add** a reminder, choosing a **time** and one or more **days**.
  - [ ] The **time picker** matches your phone: a **spinning wheel** on iPhone, the
        standard **clock dial** on Android.
- [ ] You **can't save** a reminder with no days selected.
- [ ] You can **edit** an existing reminder and **delete** one.
- [ ] Saved reminders show the correct **time** and **days**.

### 6b. Confirming a reminder actually fires

**Steps:**
1. Make sure **notifications are enabled** for Doxa (Section 7).
2. Add a reminder set for a **couple of minutes from now**, on **today's** day
   of the week.
3. Leave the app (lock the phone or switch to another app) and wait.

**What you should see:**
- [ ] A **notification appears at the set time**, on the chosen day.
- [ ] Tapping it opens the app sensibly.
- [ ] If you set **two reminders for the same time**, you get **one**
      notification, not several.
- [ ] A reminder set for a day that **isn't** selected does **not** fire.
- [ ] If notifications are turned **off**, the Reminders tab shows a **warning
      banner** explaining reminders won't alert you.

---

## Section 7 — Notifications

- [ ] After signing up (or from the relevant screens) you're offered the chance
      to **turn on notifications**; this prompt hides once they're already on.
- [ ] **Settings → Notifications** lets you review/enable notification permission.
- [ ] With permission granted, reminders fire as described in Section 6b.

---

## Section 8 — Signing up for news & updates

*Two entry points — test whichever you reach.*

**During setup** (Section 1) **or via Settings → Sign up for updates:**

- [ ] Enter a **name** and **email**, with two tick-boxes ("Updates about my
      people group" and "Updates from Doxa"), both on by default.
- [ ] Leaving name/email blank, or an invalid email, is **rejected** with a warning.
- [ ] On success, a **thank-you message** appears telling you to **check your
      email to confirm**, showing the email you entered.

---

## Section 9 — Email verification

- [ ] Go to **Settings → Account**. Your email appears **partly hidden** for
      privacy (e.g. `n***@g***.org`).
- [ ] Before confirming, it shows **"Unverified"** (amber ⚠️).
- [ ] Open your inbox, find the Doxa email, and tap the **confirmation link**.
- [ ] Back in **Settings → Account** (leave and re-enter if needed) it now shows
      **"Verified"** (green ✔️).

**Resend button** (while still unverified):

- [ ] Tapping **Resend verification** shows a confirmation and sends a new email.
- [ ] The button then shows a **~60-second countdown** and can't be tapped again
      until it finishes.

---

## Section 10 — Profile info

- [ ] In **Settings → Account**, tap **View profile**.
- [ ] Your **web profile opens in your phone's browser** and loads correctly.
- [ ] You can return to the app afterwards without problems.

---

## Section 11 — Feedback form

*The feedback form is now **built into the app** — it no longer opens in your browser.*

- [ ] From **Settings**, tap the **Feedback** row.
- [ ] A **feedback form opens inside the app**, **in your app's language** (it slides in
      over the tabs — you stay in the app).
- [ ] The form has:
  - [ ] **What kind of feedback?** — three choices: **Compliment**, **Suggestion**,
        **Problem** (you must pick one).
  - [ ] **Name** (optional).
  - [ ] **Email** (required; if you have an account it's **pre-filled** for you).
  - [ ] **Message** (required).
  - [ ] A **"Keep me updated"** tick-box (off by default).
- [ ] Submitting with **no type**, an **invalid/blank email**, or a **blank message** shows
      an inline warning and doesn't send.
- [ ] On success, the form is replaced by a **thank-you** message (green tick) that shows
      the **email** your feedback was sent with — all **without leaving the app**.
- [ ] Sending a lot of feedback in a short time shows a gentle "try again later" message.

> The form still automatically attaches harmless phone details (model, OS, app
> version) behind the scenes — you won't see them, and that's expected.

---

## Section 12 — Languages

- [ ] **Settings** has a **language switcher** with: English, Español,
      Português, Français, Русский, and العربية (Arabic).
- [ ] Changing the language **updates the app text** throughout.
- [ ] With **Arabic**, the layout switches to **right-to-left** and reads
      correctly (menus, arrows and prayer-day navigation still make sense).
- [ ] The **feedback form** (Section 11) opens in the newly selected language.

---

## Section 13 — App updates

- [ ] If a newer version is available, an **update banner** may appear; it can be
      dismissed and doesn't block you.
- [ ] If an update is **required**, a message blocks the app until you update
      (only expected around major releases).

---

## Section 14 — General robustness

- [ ] The app behaves sensibly with **no internet** (clear messages, no crashes;
      it recovers when back online).
- [ ] Closing and reopening the app **remembers** your people group, reminders,
      language and sign-up status.
- [ ] Nothing looks **cut off or overlapping**, including on smaller screens and
      in longer-worded languages.
- [ ] The app doesn't **crash** or freeze during normal use.

---

## Section 15 — Accessibility

*We've done a lot of work to make Doxa usable for people who need **larger text** or who
use a **screen reader**. Part **15a** is quick and everyone should try it. Part **15b**
(screen reader) is **optional/advanced** — do it if you can, but feel free to skip.*

### 15a. Larger text & display zoom (please try this)

**Steps:**
1. In your phone's settings, turn **font size** (and **display/zoom size** if available)
   up to a **large** setting. On Android: *Settings → Display → Font size / Display size*.
   On iPhone: *Settings → Accessibility → Display & Text Size → Larger Text*.
2. Reopen Doxa and walk through the main screens.

**What you should see — big text, but nothing broken:**
- [ ] Text is **larger** everywhere and the app still works.
- [ ] **Onboarding wizard:** the **Get started** button isn't jammed against the bottom;
      the sign-up step **scrolls** so you can still reach its buttons (even with the keyboard up).
- [ ] **Home:** the people-group card buttons (Profile/Share/QR) **wrap onto more than one
      line** instead of running off the edge.
- [ ] **Pray tab:** the scripture **reference/citation** line **wraps** instead of being cut off.
- [ ] **Reminders:** the **day-of-week** circles **wrap** onto a second row if needed; the
      **Delete** and **Save** buttons stack neatly rather than overflowing.
- [ ] **Notifications settings:** the "notifications enabled/disabled" heading **wraps**
      instead of being clipped.
- [ ] **Pop-ups scroll:** the **QR share** pop-up (the QR shrinks so it stays fully visible),
      the **Amen** thank-you pop-up, and confirmation pop-ups all **scroll** if they're too
      tall — nothing important is cut off or unreachable.
- [ ] In general, nothing is **cut off, overlapping, or unreachable** at the large size.

### 15b. Screen reader — *optional / advanced*

*This tests **TalkBack** (Android) or **VoiceOver** (iPhone) — the phone reads the screen
aloud and you swipe between items. It takes some getting used to; skip if you'd rather not.*

**Steps:**
1. Turn it on — Android: *Settings → Accessibility → TalkBack*. iPhone: *Settings →
   Accessibility → VoiceOver* (or triple-click the side button if you set that shortcut).
2. **Swipe right/left** to move between items; **double-tap** to activate the selected item.
3. Move through onboarding, Home, Pray, People Groups (incl. a group's details) and Reminders.

**What you should hear — things are announced sensibly:**
- [ ] Buttons are announced as **"button"**, and the bottom tabs say whether they're **selected**.
- [ ] **Icon-only** controls have spoken names, e.g. the back/forward **arrows** say
      "Back"/"Forward", the **settings** gear says "Settings", the photo **info** marker says
      "Picture credit", and the search **X** says "Clear search".
- [ ] **Photos** of a people group announce the **group's name** (decorative graphics stay silent).
- [ ] **Section titles** are announced as **headings** (you can jump between headings).
- [ ] Tappable **cards** read as a **single button** — including Home's **"Next reminder"**
      card and the bottom **"Pray for [group]"** banner (its **×** says "Dismiss reminder").
- [ ] In the reminder form, each **day circle** reads its **full name** ("Monday", "Tuesday"…)
      and whether it's selected — not just a single letter.
- [ ] On **Home**, the **"Prayed today"** badge is read as one clear status.
- [ ] After you tap **Amen**, the screen reader **speaks "Prayer recorded"**.
- [ ] On a group's **details** page, each engagement marker is read separately and speaks its
      status — **"Yes" / "No" / "Partial"** — rather than being skipped or run together.

---

## Final checklist

Priority tests are marked ⭐.

- [ ] **1** First-time setup completed
- [ ] **2** Navigation between tabs works
- [ ] **3** Home screen (group card, pray, share)
- [ ] ⭐ **4** Pray tab shows **my** group and **today's** prayers (+ Amen → **Home**, day nav)
- [ ] ⭐ **5** Viewed people group info (incl. prayer-status colours); shared QR/link opens the right group
- [ ] ⭐ **5c** Fresh install from a QR auto-selected the right group (Android)
- [ ] ⭐ **6** Reminders save **and fire** at the right time/day
- [ ] **7** Notifications enabled
- [ ] **8** News signup (with validation)
- [ ] **9** Email verified + resend cooldown
- [ ] **10** View profile in browser
- [ ] **11** Feedback form **in-app**, in correct language (with validation + thank-you)
- [ ] **12** Language switching incl. Arabic (right-to-left)
- [ ] **13** Update banner behaves
- [ ] **14** No crashes / offline handled / settings remembered
- [ ] **15** Accessibility — large text (15a); screen reader if possible (15b, optional)

Thank you! 🙏 Your testing directly shapes the app.
