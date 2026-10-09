# Agent instructions — Torah Reader (בעל קורא)

Before changing product behavior, screens, text rules, or taamim: **read the Obsidian notes**, starting at [`index.md`](index.md).

Product truth lives in the markdown tree, not in chat history. Keep the notes updated when a decision changes.

Obsidian vault = **repo root**. Links use `[[wikilinks]]`. Every child note links back to its parent.

## Start here

1. [`AGENTS.md`](AGENTS.md) — this file (always loaded)
2. [`index.md`](index.md) — what we are building + the full tree
3. Then open the **child note for that exact screen** (see table below). Do not mix rules from another window.

## Which window is the user talking about?

| If they say | Read |
|---|---|
| חלון ראשי / הבית / המסך הראשון | [[docs/screens/First Window]] |
| אימון / אימון קריאה / חלון האימון | [[docs/screens/Practice Reading]] |
| מסמיך / חלון המסמיך | [[docs/screens/Masmich]] |
| בחירת קטע / פרשה / עלייה | [[docs/screens/First Window]] + [[docs/features/Parashot and Aliyot]] |
| הגדרות | [[docs/screens/Settings]] |
| סימני יד / ירושלמי / טעמים ספרדים | [[docs/screens/Masmich]] + [[docs/features/Jerusalem Hand Signs]] + [[docs/screens/Settings]] |

## Tree (short)

```
AGENTS.md
└── index.md
    ├── docs/features/Parashot and Aliyot
    ├── docs/features/Jerusalem Hand Signs     ← מסמיך, ירושלמי
    └── docs/screens/Screens Index
        ├── docs/screens/First Window          ← בחירה בלבד
        │   └── docs/screens/Settings          ← הגדרות
        └── docs/screens/Reading Window
            ├── docs/screens/Practice Reading  ← אימון קריאה
            └── docs/screens/Masmich           ← מסמיך
```

## Locked decisions (short)

| Topic | Decision |
|---|---|
| App | Flutter — Android + iOS from day one |
| Font | Embedded **SBL Hebrew** (OpenType). Ezra SIL stays in the repo but is not the active face — Flutter has no Graphite, so Ezra mis-places taamim. Never load fonts from the network |
| Text | Open Scriptures Hebrew Bible (WLC), stored once (full), versions derived at runtime |
| State | Riverpod |
| Storage | SQLite (`sqflite`) for parsed text + sign sets; SharedPreferences for light settings |
| Audio | Future stage — design data so audio packs can swap later; not in v1 |
| Scope | 21 books only (not איוב, משלי, תהלים) |
| Direction | RTL everywhere (`Directionality.rtl`) |
| First window | Passage picker (sefer / parasha / aliyah, remembered) + practice vs מסמיך. [[docs/screens/First Window]] |
| Settings | Masmich sign pack (א+taam / name / photos), which taamim to show, preview full set, upload, remembered until changed or restored. [[docs/screens/Settings]] |
| Masmich signs | Sephardi names, Jerusalem right hand. Three packs; masmich uses Settings pack (default photos/GIF). Hands: light peach skin (not yellow emoji), cream `#FAF7F0` canvas. First-run shows starter taamim only. [[docs/features/Jerusalem Hand Signs]] |
| Masmich text | Always bare, no chapter/verse labels, no verse breaks (would reveal sof pasuk). [[docs/screens/Masmich]] |
| Word coloring | Same `colorMs` Timer engine may drive both practice and masmich. Sign-of-next-word is masmich-only. [[docs/screens/Reading Window]] |
