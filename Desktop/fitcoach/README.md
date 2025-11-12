# Conversational Macro Coach (SwiftUI • iOS 17+)

“Conversational Macro Coach” is an iOS SwiftUI experience that interviews the user via a friendly chat, builds a training-aware macro plan, and adapts when someone logs meals like “I had pie this morning.” It blends an Anthropic-calming tone with an athletic Nike accent to keep the experience inviting yet energetic.

---

## Quick Start
1. **Clone** `https://github.com/cabecaturbo/fitcoach.git`
2. **Open in Xcode 15+** (iOS 17+ deployment target).
3. **Configure secrets**  
   - Copy `Config/Secrets.example.xcconfig` → `Config/Secrets.xcconfig`.  
   - Fill in `OPENAI_API_KEY` (and optional `OPENAI_API_BASE_URL`).  
   - Add the `.xcconfig` to the project’s build settings (Debug + Release).
4. **Select a signing team** if you wrap this Swift Package in an Xcode app target.
5. **Run** on a simulator or device. No external package dependencies—pure Swift/SwiftUI.

> ✅ You can run the logic tests with `swift test` or the Xcode Test navigator.

---

## Architecture Overview

```
App/                      // App entry, DI container, tab routing
Core/
  DesignSystem/           // Tokens & shared UI components
  Models/                 // Domain objects (UserProfile, Plan, Macros…)
  Services/
    PlanEngine/           // TDEE + macro periodization + grocery synthesis
    LLM/                  // LLMClient protocol, Mock + OpenAI implementations
    ServiceRegistry.swift // Dependency wiring
  Storage/                // File-backed persistence + profile store
Features/
  Onboarding/             // Chat-style onboarding flow & gating
  Chat/                   // Logging UI + training-aware adjustments
  PlanDashboard/          // Macro rings, plan templates, explainability
  MealTimeline/           // Historical meal log per day
  Grocery/                // Grocery list grouped by aisle/storage life
  Profile/                // Read-only profile snapshot
Design/figma_prompt.md    // Figma AI handoff prompt
Config/Secrets.example.xcconfig
Tests/                    // Unit test targets (plan engine, onboarding, LLM)
Package.swift             // Swift Package manifest
README.md
```

### Key Ideas
- **Conversational onboarding**: Nine grouped steps with quick-reply chips, helper copy (“Why I’m asking”), “Skip for now” on optional questions, and Finish gating enforced by mandatory questions #20, #23, #27.
- **Plan generation**: Mifflin-St Jeor TDEE baseline, goal multipliers, training-load periodization (training/rest/high/low templates), explainability notes, and grocery list annotated by aisle and storage life.
- **Chat logging & adjustments**: `LLMClient` turns free-text into `MealEntry`, `ChatViewModel` persists with `FileStorage`, compares against template macros, and calls `suggestAdjustments` for nudge copy (e.g., heavy-day carb bumps, dessert balancing).
- **Design system**: Central tokens for color/typography/spacing/radius/motion plus reusable button styles, chips, section headers, macro rings, etc.
- **Persistence**: Thread-safe JSON storage, onboarding payloads processed by `UserProfileStore`, automatic plan regeneration when profile updates.

---

## Conversational Onboarding Questions

1. What does a typical day of eating look like for you in terms of meal times?  
2. How many meals and snacks do you usually have each day?  
3. Are there specific times you prefer to eat or times you absolutely cannot eat?  
4. Are there any foods you absolutely love or want included regularly?  
5. Are there any foods you dislike or want to avoid entirely?  
6. Do you have any dietary restrictions, allergies, or cultural/religious guidelines we should know about?  
7. Do you enjoy having a dessert or sweet treat daily or on certain days of the week?  
8. If yes, do you prefer certain types of sweets (e.g., chocolate, fruity candies, baked goods, etc.)?  
9. What are your favorite carbohydrate sources (e.g., rice, pasta, potatoes, bread, grains, etc.)?  
10. How do you feel about different protein sources? (Red meat, poultry, seafood, plant-based, whey, etc.)  
11. Are there specific vegetables or fruits you love?  
12. Are there any vegetables or fruits you really dislike?  
13. How comfortable are you with cooking at home? Do you prefer simple meals or more elaborate recipes?  
14. How much time do you typically have available each day or week for meal prep and cooking?  
15. Do you have any kitchen equipment limitations or preferences (e.g., no oven, love slow cooker, etc.)?  
16. How often do you typically go grocery shopping?  
17. Do you prefer a set weekly grocery list or a flexible one that adjusts weekly?  
18. Are there certain staples you always keep on hand?  
19. Seasonal favorites worth planning around?  
20. Recent DEXA/InBody values? Drop them in if you have them. **(Required)**  
21. If no scan, what’s your height, weight, biological sex, and estimated body fat %?  
22. Primary goals right now? (gain, loss, performance, energy, convenience…)  
23. Any supplements or meds affecting metabolism, nutrition, or body comp? (creatine, GLP-1s…) **(Required)**  
24. List them for me so I can factor them in.  
25. Any injuries or limitations I should respect?  
26. Any medical conditions I should keep in mind? (diabetes, thyroid, digestive…)  
27. How heavy is your current training load and recovery? (light, moderate, heavy, variable) **(Required)**  
28. Which days need extra fuel or recovery support?  
29. Performance focus? Endurance, speed, strength, or something else?  
30. Other health practices worth noting (hydration, fasting, sleep, stress)?  

Mandatory questions are blocked from skipping and must be answered before the Finish button unlocks.

---

## Testing & Tooling
- **Unit tests**:  
  - `Tests/PlanEngineTests.swift`: verifies training vs. rest templates and carb bias.  
  - `Tests/OnboardingFlowTests.swift`: ensures Finish gating on Q20/Q23/Q27.  
  - `Tests/LLMClientTests.swift`: checks meal parsing (“pie”) and adjustment messaging.
- **Swift Package Manager**: `Package.swift` lets you run `swift test` headlessly and integrate with CI.
- **LLM configuration**: `MockLLMClient` keeps development deterministic; flip `ServiceRegistry` to `OpenAIClient` when you’re ready for real responses.

---

## Design & Product Handoff
- Full Figma AI prompt lives in `Design/figma_prompt.md`, covering design system, onboarding flow, macro dashboard with training/rest toggles, grocery list, and chat microcopy guidelines.
- Tokens deliver a calm base palette with athletic accent color, and motion guidelines keep transitions ≤160 ms.

---

## Roadmap Ideas
- Swap in streaming OpenAI responses and a real-time adjustment co-pilot.  
- Add SwiftData or CloudKit for richer analytics, sync, and history.  
- Layer in wearable/HRV/sleep data to enrich nutrition adjustments.  
- Expand compliance loops with reminders, habit tracking, and coach follow-ups.

---

Hand this repo straight to your morning engineering standup—they’ll know exactly how to run it, how onboarding flows, and where to extend the macro coach next. 💪
