# Conversational Macro Coach (iOS, SwiftUI)

A chat-first macro tracker that interviews users, generates training-aware nutrition plans, and adjusts on the fly when daily intake shifts (e.g. “I had pie this morning.”)

## Features
- Conversational onboarding grouped in nine steps with mandatory body composition (#20), supplements/meds (#23), and training load & recovery (#27).
- Training-aware plan generation (Mifflin-St Jeor, macro periodization, grocery list).
- Chat logging that parses free-form meal entries and nudges adjustments based on training context.
- Modular SwiftUI architecture with design tokens, reusable components, and persistent storage.
- Mock and OpenAI-ready LLM clients with deterministic fallbacks for local development.

## Project Structure
```
App/                     # App container, routing, tab shell
Core/
  DesignSystem/          # Design tokens and shared components
  Models/                # Domain models (user, plan, macros, questions)
  Services/
    PlanEngine/          # TDEE + macro periodization logic
    LLM/                 # LLMClient protocol + mock/openAI impls
  Storage/               # File-based persistence + observable stores
Features/
  Onboarding/            # Chat-style onboarding flow and gating
  Chat/                  # Coach chat for logging + auto adjustments
  PlanDashboard/         # Macro rings, training/rest toggles, grocery list
  MealTimeline/          # Daily meal timeline derived from logs
  Grocery/               # Grocery list by aisle + storage tags
  Profile/               # Read-only profile snapshot
Design/figma_prompt.md   # Prompt for Figma AI
Config/Secrets.example.xcconfig
Tests/                   # Unit tests (plan engine, onboarding gating, LLM parsing)
Package.swift            # SPM manifest for logic + tests
```

## Getting Started
1. **Clone & open**: Open the folder in Xcode 15+ (iOS 17 minimum).
2. **Configure secrets**:
   - Duplicate `Config/Secrets.example.xcconfig` to `Config/Secrets.xcconfig`.
   - Populate `OPENAI_API_KEY` (and `OPENAI_API_BASE_URL` if self-hosting).
   - In Xcode, add the `.xcconfig` file to the project’s configurations (Debug/Release).
3. **Update bundle identifiers** and signing if you create an Xcode project.
4. **Install dependencies**: The project is pure Swift/SwiftUI; no external package dependencies beyond the mock LLM implementation.
5. **Run** the app on iOS 17+ simulator or device.

## LLM Configuration
- `MockLLMClient` powers previews and offline development.
- `OpenAIClient` is stubbed to proxy to the mock until an API key is provided.
- Swap clients in `ServiceRegistry.bootstrap()` once ready to call the live API.

## Storage
- `FileStorage` persists the user profile, plan, and logs as JSON in the app’s documents directory.
- `UserProfileStore` bridges onboarding payloads into stored `UserProfile` instances and refreshes plans automatically.

## Testing
- Unit tests live under `Tests/` and exercise:
  - Macro template generation & carb bias for heavy training.
  - Mandatory onboarding gating (#20, #23, #27).
  - Meal parsing + adjustment nudges from the mock LLM client.
- Run with `swift test` (SPM) or from Xcode’s Test navigator.

## Design Prompt
- Full Figma AI prompt is in `Design/figma_prompt.md`.

## Roadmap Ideas
- Integrate live OpenAI responses and streaming chat.
- Add SwiftData-backed storage for richer analytics and syncing.
- Expand adjustment engine with HRV/sleep tracker integrations.

