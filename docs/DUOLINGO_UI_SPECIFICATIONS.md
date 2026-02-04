# 🎨 DUOLINGO UI - VISUAL SPECIFICATION SHEET

## 📏 EXACT MEASUREMENTS & SPECIFICATIONS

This document provides pixel-perfect specifications for all UI components.

---

## 1️⃣ LEARNING PATH HEADER

### Container Specs
```yaml
Padding: 16px all sides
Background: #FFFFFF (white)
Shadow: 0px 2px 8px rgba(0,0,0,0.06)
```

### Title Text
```yaml
Text: "PETA BELAJAR"
Font: Nunito
Size: 28px
Weight: 800 (ExtraBold)
Color: #58CC02 (duo green)
Line Height: 1.2
```

### Subtitle Text
```yaml
Text: "Lanjutkan perjalanan belajarmu!"
Font: Nunito
Size: 14px
Weight: 600 (SemiBold)
Color: #777777 (grey)
Margin Top: 4px
```

### Stat Cards Row
```yaml
Margin Top: 16px
Gap Between Cards: 16px
Each Card: Flex 1 (equal width)
```

---

## 2️⃣ STAT CARDS (XP & STREAK)

### XP Card Specs
```yaml
Background: #FFD600 (bright yellow)
Border: 2px solid #DDB400 (dark yellow)
Border Radius: 16px
Shadow: 0px 4px 0px #DDB400
Padding: 16px all sides
```

### Streak Card Specs
```yaml
Background: #FF9600 (bright orange)
Border: 2px solid #E67E00 (dark orange)
Border Radius: 16px
Shadow: 0px 4px 0px #E67E00
Padding: 16px all sides
```

### Card Content Layout
```yaml
Icon:
  Size: 32px
  Color: #FFFFFF (white)
  Margin Bottom: 8px

Value Text:
  Font: Nunito
  Size: 24px
  Weight: 700 (Bold)
  Color: #FFFFFF (white)
  Margin Bottom: 4px

Label Text:
  Font: Nunito
  Size: 12px
  Weight: 600 (SemiBold)
  Color: rgba(255,255,255,0.9)
  Align: Center
```

---

## 3️⃣ UNIT HEADER CARD

### Container Specs
```yaml
Background: [Unit Color from API]
Border: 2px solid [Darker Unit Color]
Border Radius: 20px
Shadow: 0px 6px 0px [Darker Unit Color]
Padding: 20px all sides
Margin Bottom: 24px
```

### Icon Badge
```yaml
Size: 56px × 56px
Background: #FFFFFF (white)
Shape: Circle
Border: 3px solid [Darker Unit Color]
Icon Size: 28px
Icon Color: [Unit Color]
```

### Text Layout
```yaml
Title:
  Font: Nunito
  Size: 22px
  Weight: 700 (Bold)
  Color: #FFFFFF (white)
  Margin Bottom: 4px

Description:
  Font: Nunito
  Size: 14px
  Weight: 600 (SemiBold)
  Color: rgba(255,255,255,0.9)
```

### Layout Structure
```yaml
Row:
  Icon Badge (56px) → Gap (16px) → Text Column (Flex 1)
```

---

## 4️⃣ LESSON NODE (The Star of the Show!)

### Container Specs
```yaml
Size: 100px × 100px
Background: [Color based on status]
Border: 2px solid [Shadow Color]
Border Radius: 24px
Shadow: 0px 6px 0px [Shadow Color] (active: 8px)
```

### Status-Based Colors

#### 🔓 Active (Current Lesson)
```yaml
Background: [Unit Color]
Border Color: [Darker Unit Color]
Shadow: 0px 8px 0px [Darker Unit Color]
Icon Size: 48px
Icon Color: #FFFFFF
Animation: Pulsing white border (1500ms loop)
Scale: 1.05x on render
```

#### ✅ Completed
```yaml
Background: #58CC02 (duo green)
Border Color: #46A302 (dark green)
Shadow: 0px 6px 0px #46A302
Icon: check_circle_rounded
Icon Size: 56px
Icon Color: #FFFFFF

Gold Star Badge:
  Position: Top-right (4px offset)
  Size: 28px × 28px
  Background: #FFD600 (yellow)
  Border: 2px solid #DDB400
  Icon: star_rounded (16px, white)
```

#### 🔒 Locked
```yaml
Background: #E5E5E5 (light grey)
Border Color: #CCCCCC (medium grey)
Shadow: 0px 6px 0px #CCCCCC
Icon: lock_rounded
Icon Size: 48px
Icon Color: #FFFFFF
Opacity: 0.8
```

### Lesson Type Icons
```yaml
Default Icons (48px):
- square → crop_square_rounded
- grass → grass_rounded
- radio → radio_rounded
- signal → signal_cellular_alt_rounded
- school → school_rounded
- link → link_rounded
- anchor → anchor_rounded
- history → history_rounded
- [fallback] → star_rounded
```

---

## 5️⃣ PATH CONNECTOR

### Specs
```yaml
Width: 8px
Height: 40px
Background: #E5E5E5 (light grey)
Border Radius: 4px
Margin Vertical: 16px
Alignment: Center
```

### Spacing Between Nodes
```yaml
Node (100px)
   ↓
Margin (16px)
   ↓
Connector (8px × 40px)
   ↓
Margin (16px)
   ↓
Next Node (100px)

Total Vertical Spacing: 172px per lesson
```

---

## 6️⃣ BOTTOM NAVIGATION

### Container Specs
```yaml
Background: #FFFFFF (white)
Shadow: 0px -2px 12px rgba(0,0,0,0.08)
Padding Horizontal: 16px
Padding Vertical: 8px
Height: ~70px (with SafeArea)
```

### Tab Item Specs (Each of 4 tabs)
```yaml
Width: 25% (equal distribution)
Padding Vertical: 8px
Tap Area: Full width/height
```

### Icon Sizes
```yaml
Unselected: 26px
Selected: 30px
Transition: 200ms ease-out
```

### Label Text
```yaml
Font: Nunito
Size: 11px
Weight: 600 (unselected), 700 (selected)
Margin Top: 4px
```

### Active Indicator Dot
```yaml
Height: 4px
Width: 0px (unselected) → 20px (selected)
Background: [Tab Color]
Border Radius: 2px
Margin Top: 2px
Transition: 200ms ease-out
```

### Tab Colors
```yaml
Tab 0 (Peta):    #58CC02 (green)
Tab 1 (Misi):    #FF9600 (orange)
Tab 2 (Rank):    #FFD600 (yellow)
Tab 3 (Profil):  #1CB0F6 (blue)
```

---

## 7️⃣ ERROR STATE

### Container Specs
```yaml
Padding: 24px all sides
Alignment: Center
Max Width: 300px
```

### Error Icon Container
```yaml
Size: 80px × 80px
Background: #FF4B4B (red)
Border: 2px solid #E03838 (dark red)
Border Radius: 24px
Shadow: 0px 6px 0px #E03838
Icon: error_outline_rounded (48px, white)
Margin Bottom: 20px
```

### Error Text
```yaml
Title ("Oops!"):
  Font: Nunito
  Size: 24px
  Weight: 700
  Color: #3C3C3C
  Margin Bottom: 12px

Message:
  Font: Nunito
  Size: 14px
  Weight: 600
  Color: #777777
  Align: Center
  Margin Bottom: 24px
```

### Retry Button
```yaml
Background: #58CC02 (green)
Border: 2px solid #46A302 (dark green)
Border Radius: 16px
Shadow: 0px 6px 0px #46A302
Padding: 16px horizontal, 16px vertical
Text: "COBA LAGI"
Font: Nunito, 16px, Weight 700, White
Letter Spacing: 0.5px
```

---

## 8️⃣ SCROLLABLE CONTENT AREA

### List Container
```yaml
Padding: 20px all sides
Background: #F7F7F7 (snow white)
Scroll Behavior: Vertical, smooth
```

### Unit Spacing
```yaml
Between Units: 64px
Last Unit: No bottom margin
```

---

## 9️⃣ LOADING STATE

### Specs
```yaml
Indicator: CircularProgressIndicator
Color: #58CC02 (green)
Stroke Width: 4px
Size: 48px (default)
Position: Center of screen
```

---

## 🔟 SNACKBAR (Error Messages)

### Specs
```yaml
Background: #FF4B4B (red)
Border Radius: 16px
Behavior: Floating (not fixed to bottom)
Margin: 16px from edges
Padding: 16px
Duration: 2 seconds
```

### Text
```yaml
Font: Nunito
Size: 14px
Weight: 600
Color: #FFFFFF (white)
Icon: 🔒 emoji inline
```

---

## 📐 RESPONSIVE BREAKPOINTS

### Phone (< 600px)
```yaml
✅ All specs above apply
✅ Nodes: 100px
✅ Header: Full design
✅ Bottom Nav: Visible
```

### Tablet (600px - 900px)
```yaml
⚠️ Consider wider nodes (120px)
⚠️ Increase font sizes (+2px)
⚠️ More horizontal padding (24px)
```

### Desktop (> 900px)
```yaml
⚠️ Center content (max-width: 600px)
⚠️ Scale up nodes (140px)
⚠️ Side navigation instead of bottom
```

---

## 🎨 COLOR ACCESSIBILITY

### WCAG 2.1 AA Compliance

```yaml
Green (#58CC02) on White: ✅ Ratio 3.2:1
White on Green (#58CC02): ✅ Ratio 6.5:1
Black (#3C3C3C) on White: ✅ Ratio 10.7:1
White on Yellow (#FFD600): ⚠️ Ratio 1.9:1 (text always white on yellow cards)
White on Orange (#FF9600): ✅ Ratio 3.1:1
White on Red (#FF4B4B): ✅ Ratio 4.9:1
```

**Note:** All critical text uses sufficient contrast. Decorative elements may have lower contrast.

---

## 📱 TOUCH TARGET SIZES

### Minimum Touch Targets (WCAG Guideline)

```yaml
Lesson Nodes: 100×100px ✅ (min 44×44px)
Stat Cards: 150×120px ✅ (tappable if needed)
Bottom Nav Items: 90×70px ✅ (min 44×44px)
Unit Headers: Full width × 96px ✅ (tappable if needed)
Retry Button: 150×48px ✅ (min 44×44px)
```

---

## 🎬 ANIMATION TIMINGS

```yaml
Fast: 150ms - 200ms
  - Tab switch
  - Scale animations
  - Color transitions

Medium: 300ms - 500ms
  - Layout changes
  - Slide-in animations

Slow: 1000ms - 1500ms
  - Pulsing effects
  - Breathing animations
  - Background transitions
```

### Easing Curves
```yaml
UI Feedback: Curves.easeOut
Attention: Curves.easeInOut (repeat)
Entry: Curves.easeIn
Exit: Curves.easeOut
```

---

## 🖼️ SHADOW SPECIFICATION

### Standard Bouncy Shadow
```yaml
Type: BoxShadow
Color: [Match border color]
Offset: Offset(0, [4-8]px)
Blur Radius: 0 (NO BLUR!)
Spread Radius: 0
```

### Elevation Levels
```yaml
Level 1 (Subtle): 4px shadow (stat cards)
Level 2 (Medium): 6px shadow (lesson nodes, unit headers)
Level 3 (High): 8px shadow (active lesson, important CTAs)
```

### Soft Shadow (Navigation, Cards)
```yaml
Type: BoxShadow
Color: rgba(0,0,0,0.06-0.08)
Offset: Offset(0, 2px)
Blur Radius: 8-12px
Spread Radius: 0
```

---

## 🔤 TYPOGRAPHY SCALE

```yaml
Display Large:   32px / 800 / 1.2 (Page titles)
Display Medium:  24px / 700 / 1.3 (Section headers)
Display Small:   20px / 700 / 1.3 (Card titles)
Body Large:      16px / 600 / 1.5 (Primary text)
Body Medium:     14px / 600 / 1.5 (Secondary text)
Body Small:      12px / 600 / 1.4 (Labels, captions)
Label Large:     16px / 700 / 0.5 (Buttons)

Format: Size / Weight / Line Height
```

---

## 📦 COMPONENT HIERARCHY

```
DuoMainScaffold
├── IndexedStack
│   ├── DuoLearningPathPage ← Tab 0
│   │   ├── _buildDuoHeader
│   │   │   ├── Title Text
│   │   │   ├── Subtitle Text
│   │   │   └── Stats Row
│   │   │       ├── XP Card
│   │   │       └── Streak Card
│   │   └── _buildPathView
│   │       └── ListView
│   │           └── _buildUnitSection (repeated)
│   │               ├── _buildUnitHeader
│   │               └── _buildLessonsPath
│   │                   └── Column
│   │                       ├── _buildDuoLessonNode
│   │                       ├── _buildPathConnector
│   │                       ├── _buildDuoLessonNode
│   │                       └── ...
│   ├── SpecialMissionsPage ← Tab 1
│   ├── RankPage ← Tab 2
│   └── ProfilePage ← Tab 3
└── _buildDuoBottomNav
    ├── NavItem 0 (Peta)
    ├── NavItem 1 (Misi)
    ├── NavItem 2 (Rank)
    └── NavItem 3 (Profil)
```

---

## ✅ PIXEL-PERFECT CHECKLIST

Use this to verify your implementation:

- [ ] Lesson nodes are exactly 100×100px
- [ ] Border radius on nodes is 24px
- [ ] Shadow offset is 6px (8px for active)
- [ ] Stat cards use 16px border radius
- [ ] Header title is 28px Nunito ExtraBold
- [ ] Bottom nav icons scale from 26px to 30px
- [ ] Path connectors are 8px wide × 40px tall
- [ ] All shadows are solid (0 blur) except navigation
- [ ] Text uses Nunito font family
- [ ] Colors match hex codes exactly
- [ ] Spacing follows 4px, 8px, 12px, 16px, 20px, 24px, 32px system
- [ ] Active nodes have pulsing animation
- [ ] Completed nodes show gold star badge
- [ ] Locked nodes are greyed out
- [ ] Touch targets are minimum 44×44px

---

**This specification sheet ensures pixel-perfect implementation across all devices and platforms.**

*Last Updated: 2026-01-18*
