# Changelog

## 2.2.0+32 - 2026-09-21

Features:
- make verse numbers superscript instead of sub
- enter map a bit more zoomed out

Bug fixes:
- Doxa --> DOXA
- stop a dropped connection permanently blanking a people-group photo
- make a failed people-group photo visible
- align hi, zh and it translations with the glossary (#21)
- align Spanish with the reviewed glossary (#19)
- align Portuguese with the reviewed glossary (#20)
- order languages alphabetically;
- use the glossary label family for the German engagement status

## 2.1.2+31 - 2026-09-18

Features:
- enter map a bit more zoomed out

Bug fixes:
- stop a dropped connection permanently blanking a people-group photo
- make a failed people-group photo visible, and drop AppImage's dead aspectRatio

## 2.1.1+30 - 2026-09-18

Features:
- add country label to uupg list cards
- add rolling verses x30 to thankyou modal
- add image and data caching
- add 'N people praying with you now banner
- ability to choose 5 people groups
- add map showing selected peoples
- remove donate, and move feedback to settings
- combine QR code into share button
- translate the app into German, Hindi, Italian, Romanian, Chinese

Bug fixes:
- deep linking of prayer reminder
- Doxa --> DOXA

## 2.1.0+29 - 2026-09-17

Bug fixes:
- deep linking of prayer reminder

## 2.0.0+28 - 2026-09-17

Features:
- add country label to uupg list cards
- add rolling verses x30 to thankyou modal
- add image and data caching
- add 'N people praying with you now banner
- ability to choose 5 people groups
- add map showing selected peoples
- use heart for selected pins; feat: add colour coding for prayer commitment
- remove donate, and move feedback to settings
- make background pattern pop a little more
- combine QR code into share button
- translate the app into German, Hindi, Italian, Romanian, Chinese

## 1.17.0+27 - 2026-07-30

Features:
- add hyphenations to words split onto multiple lines

Bug fixes:
- remve flyout headers fixed height to allow for wrapping

## 1.16.0+26 - 2026-07-28

Features:
- add skeleton loaders for all network content

Bug fixes:
- overflowing large button text in button bars
- app to show notification dot when notifications are in the tray
- change 24-hour to Daily prayer coverage

Building system:
- Translation updates

## 1.15.0+25 - 2026-07-23

Feature:
Add accessibility for zoom and screen reader
-

## 1.14.0+23 - 2026-07-23

Features:
Add accessibility for zoom and screen readers

## 1.14.0+21 - 2026-07-15

Bug fixes:
- refactor ButtonBar to ButtonBarWrap

## 1.13.0+20 - 2026-07-14

Features:
- use SCHEDULE_EXACT_ALARMS instead of USE_***

Code refactoring:
- WizardButtonBar to ButtonBar

## 1.12.0+19 - 2026-07-14

Features:
- add crashylitics
- prayer reminder banner on home page

Bug fixes:
- centralise text on screen

## 1.11.0+18 - 2026-07-03

Features:
- add deep linking of site prayer pages into the app
- show thankyou modal when amen is clicked
- fix button overflow on wizards
- feedback button
- add profile section and show redacted (un)verified email
- add push notifications to the app
- show 'enable notifications' for updates message

Bug fixes:
- overflow issues
- reverse flyover arrow directions for RTL langs
- only fire one notification for multiple alarms at same time
- resend verification cooldown

## 1.10.0+17 - 2026-06-23

Features:
- allow deep linking to people group to work on people group list

Bug fixes:
- update banner hides for 6 hours if in app update is done

## 1.9.0+16 - 2026-06-22

Features:
  - notifications settings screen
  - notice on reminders if notification permissions are off

## 1.7.0+14 - 2026-06-22

Features:
  - add notifications setting page
  - add indicator on reminder screen if notifications not enabled

Fixes:
  - improve referral linking

## 1.6.0+13 - 2026-06-22

Features:
- add copyright notice to bottom of prayer page

Bug fixes:
- back button only quits app on home screen (and then after 2 backs)
- validate news signup email and name

## 1.5.0+12 - 2026-06-22

Features:
- add copyright notice to bottom of prayer page

Bug fixes:
- back button only quits app on home screen (and then after 2 backs)
- validate news signup from

## 1.5.0+11 - 2026-06-16

Features:
- enable deep linking into the app
- add my people group section under 'Amen'

Bug fixes:
- add missing titles to prayer sections

CI/CD:
- setup fastlane release process

## 1.4.0+10 - 2026-06-16

Bug fixes:
- hide banner once playstore takes over in app update

## 1.3.0+9 - 2026-06-16

Bug fixes:
- hide banner once playstore takes over in app update

## 1.2.0+8 - 2026-06-16

Bug fixes:
- hide banner once playstore takes over in app update

## 1.0.6+6

- Initial tracked release. Subsequent entries are drafted from git commits by
  `./release.sh bump` and edited before each release.
