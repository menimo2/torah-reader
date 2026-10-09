# שני חלונות המלל

← חזרה ל-[[docs/screens/Screens Index]] · [[docs/screens/First Window]]

אחרי הבחירה בחלון הראשי יש **שני חלונות נפרדים** עם טקסט התורה. לכל אחד קובץ משלו.

| בשיחה אומרים | הקובץ |
|---|---|
| אימון / אימון קריאה / חלון האימון | [[docs/screens/Practice Reading]] |
| מסמיך / חלון המסמיך | [[docs/screens/Masmich]] |

כשמדברים על חלון אחד — זה הקובץ שמתעדכנים בו. לא מערבבים כללים בין שניהם.

ב-[[docs/screens/Practice Reading]] יש מספרי פרק/פסוק (אותיות). ב-[[docs/screens/Masmich]] **אין** — לא מספרים ולא שבירת פסוק — כדי לא לחשוף סוף פסוק.

---

## מנגנון צביעה — משותף לשני החלונות

יכול להיות שנשתמש **באותו מנגנון** בשני חלונות המלל:

- מילה־מילה, `Timer` (לא `Future.delayed`)
- משך הצבע = `colorMs` מהקטלוג [[docs/features/Jerusalem Hand Signs]]
- מהירות מה-[[docs/screens/Settings]] תכפיל אחר כך

מה **לא** משותף: הסימן של המילה הבאה, הטקסט העירום-תמיד, כפתור התחל — אלה של [[docs/screens/Masmich]] עד שנחליט אחרת ב-[[docs/screens/Practice Reading]].
