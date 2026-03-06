# Windows-to-SwiftUI Protocol

A protocol for taking **Windows development files** (web stack: Tailwind, React, HTML/CSS, etc.) and converting them to Xcode/SwiftUI compatible output.

---

## 1. Input Types: Windows / Web Development Files

These are the typical source formats when developing on Windows (no Mac/Xcode available):

| Input Type | File Extensions | Description | Conversion Strategy |
|------------|-----------------|-------------|---------------------|
| **Tailwind CSS** | `.html`, `.jsx`, `.tsx`, `*.css` | Utility classes: `flex`, `p-4`, `bg-blue-500`, `rounded-lg`, `gap-4` | Map utilities → SwiftUI modifiers |
| **React / Next.js** | `.jsx`, `.tsx`, `.js`, `.ts` | Components, `useState`, `useEffect`, props | Components → Views, hooks → `@State` / `@StateObject` |
| **Vue (SFC)** | `.vue` | Single-file components (template + script + style) | Template → SwiftUI body, script → Swift logic |
| **HTML + CSS** | `.html`, `.css`, `.scss`, `.sass` | Vanilla markup + styles | Structure → `VStack`/`HStack`, CSS → SwiftUI modifiers |
| **Tailwind config** | `tailwind.config.js`, `tailwind.config.ts` | Theme: colors, spacing, fonts, breakpoints | Extract tokens → `AscensionColors`, spacing constants |
| **CSS variables** | `:root { --primary: #2EEDC7; }` | Design tokens in CSS | Map to Swift `Color` / struct |
| **Figma exports** | HTML/CSS, sometimes Tailwind | Design-to-code output | Use as reference, rebuild in SwiftUI |
| **TypeScript types** | `.ts`, `.d.ts` | API types, interfaces | Convert to Swift structs / classes |

### Why These Show Up

- **Tailwind** — Fast to iterate on Windows; no Xcode needed; easy to preview in browser.
- **React/Vue** — Component-based, similar mental model to SwiftUI.
- **HTML/CSS** — Universal, runs anywhere; good for quick mockups.

### Conversion Reality

There is **no direct transpiler** from Tailwind/React → SwiftUI. The protocol is a **translation guide**: read the web source, extract structure + styling + behavior, then author equivalent SwiftUI.

---

## 2. Tailwind → SwiftUI Quick Reference

| Tailwind | SwiftUI |
|----------|---------|
| `flex` | `HStack` or `VStack` (depends on `flex-direction`) |
| `flex flex-col` | `VStack` |
| `flex flex-row` | `HStack` |
| `gap-4` | `.padding()` or `Spacer()` between items |
| `p-4` | `.padding(16)` (Tailwind 1 unit ≈ 4pt) |
| `p-6` | `.padding(24)` |
| `px-4 py-2` | `.padding(.horizontal, 16).padding(.vertical, 8)` |
| `m-4` | `.padding()` on parent or `.margin` (use padding) |
| `rounded-lg` | `.clipShape(RoundedRectangle(cornerRadius: 12))` |
| `rounded-full` | `.clipShape(Capsule())` or `.clipShape(Circle())` |
| `bg-black` | `.background(Color.black)` |
| `bg-blue-500` | `.background(Color.blue)` or custom `AscensionColors` |
| `text-white` | `.foregroundStyle(.white)` |
| `text-sm` | `.font(.system(size: 14))` |
| `text-lg` | `.font(.system(size: 18))` |
| `font-bold` | `.fontWeight(.bold)` |
| `w-full` | `.frame(maxWidth: .infinity)` |
| `h-screen` | `.frame(maxHeight: .infinity)` or `.ignoresSafeArea()` |
| `items-center` | `VStack(alignment: .center)` or `.frame` alignment |
| `justify-between` | `HStack` + `Spacer()` between items |
| `shadow-lg` | `.shadow(color: .black.opacity(0.15), radius: 8, y: 4)` |
| `border border-gray-300` | `.overlay(RoundedRectangle(...).stroke(Color.gray, lineWidth: 1))` |
| `hidden` / `block` | `if` / `Group` or `@ViewBuilder` |
| `hover:` | Use `Button` + `.buttonStyle` or custom gesture |

### Tailwind Config → Swift Tokens

From `tailwind.config.js`:

```js
theme: {
  extend: {
    colors: { primary: '#2EEDC7', secondary: '#1DA1F2' }
  }
}
```

→ Swift (use `Color(red:green:blue:)` or add a `Color+Hex` extension):

```swift
struct AscensionColors {
    static let primary = Color(red: 0.18, green: 0.93, blue: 0.78)   // #2EEDC7
    static let secondary = Color(red: 0.11, green: 0.63, blue: 0.95)  // #1DA1F2
}
```

---

## 3. React / Vue → SwiftUI Quick Reference

| React/Vue | SwiftUI |
|------------|---------|
| `useState(x)` | `@State private var x = ...` |
| `useEffect` | `.onAppear` / `.onChange` / `.task` |
| `props` | Function parameters or `@Binding` |
| `className="..."` | SwiftUI modifiers (see Tailwind table) |
| `{condition && <View />}` | `if condition { View() }` |
| `map()` over list | `ForEach(items) { item in ... }` |
| `onClick` | `Button(action: { ... }) { ... }` |
| `className={cn(...)}` | Conditional modifiers: `Group { if x { ... } else { ... } }` |

---

## 4. Swift File Requirements (Xcode-Compatible)

### 4.1 File Header (Required)

Every Swift file in an Xcode project should include:

```swift
//
//  [FileName].swift
//  [ProjectName]
//
//  Created by [Author] on [Date].
//

import SwiftUI
// Add: SwiftData, Foundation, etc. as needed
```

### 4.2 Module & Target Membership

- Files must live inside the **main app target folder** (e.g., `Ascension_Habit_Builder/`)
- With **PBXFileSystemSynchronizedRootGroup** (Xcode 16+): files are auto-included when placed in the synced folder
- Without file sync: add each file to the target in Xcode (File Inspector → Target Membership)

### 4.3 SwiftUI View Conventions

| Requirement | Rule |
|-------------|------|
| **View struct** | `struct ViewName: View` |
| **Body** | `var body: some View { ... }` |
| **Preview** | Include `#Preview` (iOS 17+) or `PreviewProvider` for legacy |
| **State** | Use `@State`, `@StateObject`, `@ObservedObject`, `@EnvironmentObject` appropriately |
| **Dependencies** | If using SwiftData: `@Environment(\.modelContext)`, `@Query` |

### 4.4 Preview Support (Dual Format)

```swift
// Modern (iOS 17+)
#Preview {
    MyView()
        .preferredColorScheme(.dark)
}

// Legacy (for older Xcode / broader compatibility)
struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        MyView()
            .preferredColorScheme(.dark)
    }
}
```

**If the view uses SwiftData:** provide a `modelContainer` in the preview:

```swift
#Preview {
    ContentView()
        .modelContainer(for: [Item.self, Task.self], inMemory: true)
}
```

---

## 5. Design Token Alignment

When converting from prototypes or design specs, map to a shared token system:

| Token | Swift | Hex | Usage |
|-------|-------|-----|-------|
| **BG** | `Color.black` or `AscensionColors.background` | `#000000` / `#FAF7F2` | Main background |
| **Primary** | `Color.cyan` / `AscensionColors.primary` | `#2EEDC7` / `#000000` | Primary accent / text |
| **Secondary** | `Color.blue` / `AscensionColors.secondary` | `#1DA1F2` / `#808080` | Secondary accent |
| **Card BG** | `Color.white.opacity(0.1)` | `#1C1C1E` | Card/panel background |

**Recommendation:** Define a shared `AscensionColors` (or project-specific) struct and use it consistently.

---

## 6. Integration Workflow

### Step 1: Validate Source File

- [ ] No syntax errors
- [ ] All referenced types exist (or are stubbed)
- [ ] No platform-specific APIs that don't exist on iOS
- [ ] Imports are minimal and correct

### Step 2: Add Xcode Headers

- [ ] Add standard file header
- [ ] Ensure `import SwiftUI` (and others) at top
- [ ] Add `#Preview` or `PreviewProvider` block

### Step 3: Resolve Dependencies

- [ ] If using SwiftData: ensure `@Model` types and `ModelContainer` are available
- [ ] If using `@Query`: ensure schema includes required model types
- [ ] Replace placeholder types (e.g., `TaskItem`) with project models (`Task`) where appropriate

### Step 4: Place in Xcode Project

- **With file sync:** Copy file into `Ascension_Habit_Builder/` (or equivalent app folder)
- **Without file sync:** Add file via Xcode (File → Add Files to "[Project]") and check target membership

### Step 5: Wire Into App (If Entry Point)

- [ ] Update `@main` app struct to present the new view (e.g., in `WindowGroup` or `NavigationStack`)
- [ ] Or add as destination from existing navigation (e.g., `NavigationLink`)

### Step 6: Verify Build

- [ ] Clean build (⌘⇧K) then build (⌘B)
- [ ] Run in Simulator
- [ ] Confirm preview renders in Canvas (if enabled)

---

## 7. Converting Windows Dev Files → Xcode (Checklist)

For a Tailwind/React/HTML file (e.g., developed on Windows):

| Step | Action |
|------|--------|
| 1 | **Parse** the web source: identify layout (flex/block), colors, typography, interactions |
| 2 | **Extract** design tokens from `tailwind.config.js` or CSS variables if present |
| 3 | **Map** Tailwind/HTML structure → SwiftUI (`VStack`/`HStack`, modifiers) |
| 4 | **Map** React state/hooks → `@State`, `@StateObject`, etc. |
| 5 | **Create** new `.swift` file with Xcode header and `#Preview` |
| 6 | **Place** in `Ascension_Habit_Builder/` (or `Views/` subfolder) |
| 7 | **Wire** into app (navigation, entry point) if needed |
| 8 | **Build** and verify in Simulator |

---

## 8. Naming Conventions

| Asset | Convention | Example |
|-------|------------|---------|
| **Swift files** | `[ComponentName].swift` | `AscensionDashboard.swift`, `SettingsView.swift` |
| **View structs** | PascalCase | `AscensionDashboard`, `QuoteMomentView` |
| **Preview structs** | `[ViewName]_Previews` | `AscensionDashboard_Previews` |
| **HTML previews** | `[ComponentName]_PREVIEW.html` | `AscensionDashboard_PREVIEW.html` |

---

## 9. Common Pitfalls

| Issue | Fix |
|-------|-----|
| "Cannot find type 'X' in scope" | Add import or ensure type is in same target |
| Preview crashes / blank | Add `.modelContainer(for: [...], inMemory: true)` for SwiftData views |
| File not in build | Check target membership or folder is inside synced root |
| Duplicate symbols | Rename or move conflicting types |
| Old API (e.g., `.foregroundColor`) | Use `.foregroundStyle` (iOS 15+) |
| Missing `@main` | Only one `@main` struct per app; others are views/support types |
| Flexbox ≠ SwiftUI | `flex-wrap`, `flex-grow` don't map 1:1; use `LazyVGrid`/`LazyHGrid` for grids |
| Tailwind spacing scale | 1 unit = 4pt; `p-4` = 16pt, `gap-6` = 24pt |

---

## 10. Project Structure Reference

```
Ascension_Habit_Builder/
├── Ascension_Habit_BuilderApp.swift   # @main entry
├── ContentView.swift
├── Task.swift
├── Item.swift
├── SettingsView.swift
├── TaskLibraryView.swift
├── InspirationalQuotes.swift
├── [NewView].swift                   # Add new views here
└── Assets.xcassets/
```

---

## 11. Protocol Summary

1. **Parse** Windows/web source (Tailwind, React, HTML/CSS)  
2. **Extract** design tokens from config or CSS  
3. **Map** layout + styling → SwiftUI modifiers (use Section 2–3 reference)  
4. **Map** state/logic → `@State`, `@StateObject`, etc.  
5. **Create** Swift file with Xcode headers and preview  
6. **Place** in app target folder and wire into navigation  
7. **Build** and verify in Simulator  

*Protocol: Windows-to-SwiftUI — Web dev files (Tailwind, React, HTML) → Xcode-ready SwiftUI.*

---

## See Also

- **Ascension Dual-Sync** (`DashboardUI/.cursorrules`) — For generating SwiftUI + HTML preview in lockstep when creating new UI components.
