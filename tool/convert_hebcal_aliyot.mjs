import fs from 'fs';

const hebrewNames = {
  Bereshit: 'בראשית',
  Noach: 'נח',
  'Lech-Lecha': 'לך לך',
  Vayera: 'וירא',
  'Chayei Sara': 'חיי שרה',
  Toldot: 'תולדות',
  Vayetzei: 'ויצא',
  Vayishlach: 'וישלח',
  Vayeshev: 'וישב',
  Miketz: 'מקץ',
  Vayigash: 'ויגש',
  Vayechi: 'ויחי',
  Shemot: 'שמות',
  Vaera: 'וארא',
  Bo: 'בא',
  Beshalach: 'בשלח',
  Yitro: 'יתרו',
  Mishpatim: 'משפטים',
  Terumah: 'תרומה',
  Tetzaveh: 'תצוה',
  'Ki Tisa': 'כי תשא',
  Vayakhel: 'ויקהל',
  Pekudei: 'פקודי',
  Vayikra: 'ויקרא',
  Tzav: 'צו',
  Shmini: 'שמיני',
  Tazria: 'תזריע',
  Metzora: 'מצורע',
  'Achrei Mot': 'אחרי מות',
  Kedoshim: 'קדושים',
  Emor: 'אמור',
  Behar: 'בהר',
  Bechukotai: 'בחוקתי',
  Bamidbar: 'במדבר',
  Nasso: 'נשא',
  "Beha'alotcha": 'בהעלותך',
  "Sh'lach": 'שלח',
  Korach: 'קרח',
  Chukat: 'חוקת',
  Balak: 'בלק',
  Pinchas: 'פינחס',
  Matot: 'מטות',
  Masei: 'מסעי',
  Devarim: 'דברים',
  Vaetchanan: 'ואתחנן',
  Eikev: 'עקב',
  "Re'eh": 'ראה',
  Shoftim: 'שופטים',
  'Ki Teitzei': 'כי תצא',
  'Ki Tavo': 'כי תבוא',
  Nitzavim: 'ניצבים',
  Vayeilech: 'וילך',
  "Ha'azinu": 'האזינו',
  'Vezot Haberakhah': 'וזאת הברכה',
  'Vayakhel-Pekudei': 'ויקהל-פקודי',
  'Tazria-Metzora': 'תזריע-מצורע',
  'Achrei Mot-Kedoshim': 'אחרי מות-קדושים',
  'Behar-Bechukotai': 'בהר-בחוקתי',
  'Chukat-Balak': 'חוקת-בלק',
  'Matot-Masei': 'מטות-מסעי',
  'Nitzavim-Vayeilech': 'ניצבים-וילך',
};

const bookOsis = { 1: 'Gen', 2: 'Exod', 3: 'Lev', 4: 'Num', 5: 'Deut' };

const combinedAfter = {
  Pekudei: 'Vayakhel-Pekudei',
  Metzora: 'Tazria-Metzora',
  Kedoshim: 'Achrei Mot-Kedoshim',
  Bechukotai: 'Behar-Bechukotai',
  Balak: 'Chukat-Balak',
  Masei: 'Matot-Masei',
  Vayeilech: 'Nitzavim-Vayeilech',
};

function parseRef(ref) {
  const [chapter, verse] = ref.split(':').map(Number);
  return { chapter, verse };
}

function aliyotOf(entry) {
  const out = {};
  for (const [key, val] of Object.entries(entry.fullkriyah)) {
    out[key] = { start: parseRef(val[0]), end: parseRef(val[1]) };
  }
  return out;
}

const src = fs
  .readFileSync(process.argv[2], 'utf8')
  .replace(/^export default /, '')
  .replace(/\/\/# sourceMappingURL=.*$/m, '')
  .replace(/;\s*$/, '')
  .trim();
const data = Function(`"use strict"; return (${src})`)();

const combinedIds = [
  'Vayakhel-Pekudei',
  'Tazria-Metzora',
  'Achrei Mot-Kedoshim',
  'Behar-Bechukotai',
  'Chukat-Balak',
  'Matot-Masei',
  'Nitzavim-Vayeilech',
];
const isCombined = (id) => combinedIds.includes(id);

const parashot = [];
let order = 0;
for (const [id, entry] of Object.entries(data)) {
  if (isCombined(id)) continue;
  if (!hebrewNames[id]) throw new Error(`missing Hebrew name: ${id}`);
  parashot.push({
    id,
    hebrewName: hebrewNames[id],
    bookOsis: bookOsis[entry.book],
    combined: false,
    order: ++order,
    aliyot: aliyotOf(entry),
  });
  const extra = combinedAfter[id];
  if (extra) {
    const comb = data[extra];
    parashot.push({
      id: extra,
      hebrewName: hebrewNames[extra],
      bookOsis: bookOsis[comb.book],
      combined: true,
      order: ++order,
      aliyot: aliyotOf(comb),
    });
  }
}

const json = {
  source: 'Hebcal leyning fullkriyah (@hebcal/leyning, BSD-2-Clause)',
  sourceUrl: 'https://github.com/hebcal/hebcal-leyning',
  parashot,
};

fs.writeFileSync(process.argv[3], JSON.stringify(json, null, 2) + '\n');
console.log(`wrote ${parashot.length} parashot`);
