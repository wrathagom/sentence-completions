# Sentence Completion App - Concept Document

## Overview

A mobile journaling app inspired by the sentence completion exercises from Nathaniel Branden's "The Six Pillars of Self-Esteem." Users complete daily sentence stems to build self-awareness and track personal growth over time.

## Platforms

- Android
- iOS
- Desktop: Windows, macOS, Linux

## Technology

### Framework: Flutter
- Single codebase for all platforms (mobile + desktop)
- Dart language (clean, easy to learn, AI tools handle it well)
- Beautiful UI out of the box
- Hot reload for fast iteration
- Strong community and Google backing

### Development Environment
- Primary development on Linux
- iOS builds via Codemagic (cloud CI/CD) or Mac Mini
- Android emulator for testing (cheap physical device optional)
- iPhone for iOS testing (already owned)

### On-Device Categorization
Start simple, escalate only if needed:
1. **Phase 1: Keyword/phrase matching** - Dictionary of keywords per category, no ML required, fast and offline
2. **Phase 2: Small trained classifier** - If keyword matching isn't accurate enough, add a lightweight ML model (TensorFlow Lite, few MB)
3. No ML chip access required for categorization

### Cloud AI (Guided Mode only)
- API calls to Claude/similar for personalized stem generation
- Only used for features that justify the cost
- Batch/cache where possible to reduce API calls

### Content Management
- **MVP approach:** Remote JSON file (hosted on S3, GitHub Pages, or CDN)
- App fetches content on startup or daily
- Edit JSON manually to add/update stems and categories
- No app store release required for content updates
- **Future:** Migrate to headless CMS (Strapi, Contentful) or build simple admin UI if JSON becomes unwieldy

### Accounts Required
- Apple Developer Program: $99/year
- Google Play Developer: $25 one-time

## Core Concept

### Sentence Completions
- Daily prompts that users complete with their own thoughts
- Stems start open-ended and can become more targeted over time
- Minimum of 1 completion per day, users can do more if desired
- Format example: "If I brought 5% more awareness to my career..."

### Categories
Life domains rather than the 6 pillars directly:
- **Broad categories:** Relationships, Career, Health
- **Sub-categories:** Kids, Spouse, Girlfriend, Passions, Hobbies, etc.

### Progression
- May start everyone with the same foundational prompts
- App learns from engagement (what they write more about, what they skip, what they return to)
- Becomes more personalized over time based on behavior

### User Control
- Users can choose their category each day
- Option to "step back" if prompts feel too narrow
- Three options per day:
  - AI-recommended stem
  - Choose your own category
  - "Surprise me" (random from neglected categories)
- Periodic check-in: "You've been focusing on [family]. Want to keep going deep or explore other areas?"

## Resurfacing & Growth Tracking

- Same questions resurface at 3 months, 6 months, etc.
- User answers again WITHOUT seeing their old answer first
- After completing, show the comparison
- Visualize growth over time
- Acknowledge that growth isn't linear (someone might write hopeful, then darker, then hopeful again—that's okay)

## Privacy Modes

Users choose their mode with full transparency about tradeoffs:

### Private Mode
- No storage, no AI
- Completions exist only in the session, then vanish
- App is a daily prompt tool, not a journal
- Minimal features but maximum privacy

### Journal Mode
- Storage enabled (local or encrypted cloud)
- No AI analysis
- Gets: history, resurfacing, 3/6 month comparisons
- Category selection is manual or simple rotation

### Guided Mode
- Storage + AI
- Full experience: smart stem selection, pattern recognition, personalized recommendations
- Requires sending data to AI service

### Mode Switching
- Users can move between modes
- Upgrading is easy (start storing/analyzing from that point)
- Downgrading needs consideration (export data? delete?)

## Privacy & Trust

- Private, protected journaling experience
- No social features
- Transparent consent: explain exactly what we do with stored data and AI processing
- Frame as "modes" not "permissions" for better UX
- Consider:
  - Neutral app name/icon (doesn't scream "therapy journal")
  - Biometric/PIN lock
  - Quick-hide if needed

## Analytics & Usage Data

### Consent Model
- Separate opt-in toggle, independent from privacy modes
- "Share anonymous usage data to help us improve the app"
- Clear explanation: "This includes things like which features you use and how often—never your actual journal entries"
- Users can be in Journal mode but decline analytics, or vice versa

### What to Track
- **Categorization accuracy:** When users re-categorize something the app auto-categorized (gold for improving keyword matching)
- **Retention metrics:** Daily/weekly/monthly active users, streaks, drop-off points
- **Feature usage:** Which categories, completions per session, mode distribution
- **Funnel data:** Onboarding completion rates, mode selection choices
- **Errors:** Crash reporting, failed syncs

### Tool Options
| Tool | Pros | Cons |
|------|------|------|
| Firebase Analytics | Free, powerful, Flutter SDK | It's Google |
| PostHog | Open source, can self-host | More setup |
| Mixpanel/Amplitude | Great product analytics | Paid at scale |
| Custom endpoint | Full control, minimal | Build everything yourself |

### Privacy-First Approach
- All analytics data is anonymous (no journal content ever sent)
- Respect user's choice—if they opt out, send nothing
- Consider self-hosted option (PostHog) for maximum trust

## Pricing Model

### One-Time Purchase: $9.99
- Includes all modes (Private, Journal, Guided)
- No subscriptions
- "Pay once, own forever"
- Marketing angle: "No subscription. No ads. Your private journal, forever."

### Economics
- ~$7 after app store cut
- Bet on natural churn: most users won't stay active for years
- Heavy users subsidized by those who churn early
- AI costs trend downward over time

### Cost Management
- On-device AI where possible (categorization, neglected category detection)
- API only for high-value features (personalized stem generation)
- Batch/cache stems rather than real-time per request

### Tip Jar
- Available in settings
- Surface to power users after 6+ months of consistent use
- Transparent messaging about economics
- Tone: celebrate their commitment first, acknowledge the economics honestly, make the ask without pressure
- Example message:
  > "You've been showing up for yourself for 8 months straight. That's genuinely impressive.
  >
  > Quick note: we built this app without subscriptions because we hate them too. For power users like you, the AI costs have exceeded what you paid—which is totally fine, that was the deal.
  >
  > If you want to help us keep this sustainable for everyone, there's a tip jar in settings. No pressure either way. Keep writing."

## MVP Plan

**Start with Journal Mode:**
- Core loop: daily prompts, completions, history, resurfacing
- No AI integration initially
- Simpler backend, no per-query costs
- Gather real user data about category preferences and stem engagement
- Informs the AI layer when added later

**Guided Mode comes later:**
- Layer AI on top once core loop is proven
- Understand actual usage patterns first
- Figure out true AI costs with real data

## AI Features (Future - Guided Mode)

- Personalized stem generation based on history
- Pattern recognition across entries
- Sentiment tracking over time
- Smart category recommendations
- Monthly progress reports/insights

## Open Questions

- Specific sentence stems to include
- Exact onboarding flow
- Cloud sync implementation details
- Detailed UI/UX design
- Desktop-specific UX considerations (keyboard shortcuts, window management, etc.)
