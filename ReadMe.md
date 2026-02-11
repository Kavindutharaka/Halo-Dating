###Halo dating app

So i need to build a dating app for sri lankans simple and basic one. Here are simple description of our app 
-A simple, safe dating app for Sri Lanka.
-Everyone can join and chat.
-user should be age 18 or above 
-only ONE Premium membership.
-Verified women get Premium FREE.
-Men pay for Premium.
-No super likes, no boosts, no coins.

There are only two types of users in this app
-normal users
-premium users


AUTHENTICATION:
- Phone number login
- SMS OTP verification
- Mandatory before app usage

Lets say i (21M)join to the Halo app i registered i created a account. I should complete this to publish my profile otherwise it wont go online 
 - Name
  - Date of Birth (auto age)
  - Gender
  - City
  - Short bio
  - Profile photos
So im a 21m and i dont have premium membership i get these as features in free version
- Like / Pass profilesliited (only 15 profiles a day)
- Mutual like creates a match(but cant see who matched with you  or chat with in free version only in premium )
- Edit profile
- Report user
- Block user
 
And if i buy premium version i get features like 
-browse profile(filter the profiles location age etc)
-and see who matched me and chat with them 
-premium badge 
-Priority profile visibility
- No ads

PREMIUM PRICE:
- $10 USD / month

As above when a user joins the app and making a profile he or she should get following questions so then easier to reconise his category and other things  
PERSONALITY:
- Two truths and a lie about me…
- The key to my heart is…
- My love language is…
- Green flags I look for…
- One thing I will never tolerate…

LIFESTYLE:
- My typical Sunday looks like…
- My simple pleasures…
- I get excited about…
- Colombo life or peaceful hometown?
- Tea or coffee?

RELATIONSHIP:
- I’m looking for…
- My ideal date night…
- We’ll get along if…
- Together we could…

FUN:
- Dating me is like…
- Let’s debate this…



MATCHING LOGIC:
- User A likes User B
- User B likes User A
- Match created
- Chat unlocked
- No AI matching
- No ranking algorithm
- Pure rule-based logic

CHAT:
- Only between matched users(only premium memebrs can start a chat )
- Text messages (MVP)
- Images optional later
- No voice/video calls initially


 Verification Status:
- none
- pending
- approved
- rejected

After Approval:
- Verified badge shown on profile
- Female users → Premium activated automatically
- Male users → Verified badge only

PRIVACY:
- ID & selfie never shown publicly
- Accessible only by admins
- Stored securely
- Can be deleted after verification if required

PAYMENTS:
- Stripe integration
- Credit / Debit cards
- Apple Pay
- Google Pay
- Subscription-based
- On success:
  - User role → Premium
  - Premium expiry date stored

TECH STACK:
- Frontend: Flutter (Android first, iOS later)
- Backend: Firebase
  - Auth: Phone OTP
  - Database: Firestore
  - Storage: Firebase Storage
- Payments: Stripe
- Verification: KYC SDK or manual MVP flow
- Admin Panel: Web dashboard

DATABASE CORE FLAGS:
- isPremium (boolean)
- premiumUntil (timestamp)
- isVerified (boolean)
- verificationStatus (none/pending/approved/rejected)

ADMIN PANEL FEATURES:
- View verification requests
- Approve / Reject verification
- View reported users
- Ban / Suspend users
- View premium subscriptions

WHAT THIS APP IS NOT:
- No super likes
- No boosts
- No coins
- No gifts
- No swipe addiction mechanics
- No complex AI algorithms

GOAL OF MVP:
- Simple
- Fast to build
- Easy to use
- Safe
- Monetizable immediately