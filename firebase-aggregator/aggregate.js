const admin = require('firebase-admin');
const { getStartDate, getDateKey } = require('./utils');

admin.initializeApp({
  credential: admin.credential.cert(JSON.parse(process.env.FIREBASE_KEY_JSON))
});
const db = admin.firestore();

async function aggregateTopScores(mode, period) {
  const now = new Date();
  const dateKey = getDateKey(period, now);
  const start = getStartDate(period, now);

  const snapshot = await db.collection('scores')
    .where('mode', '==', mode)
    .where('timestamp', '>=', start)
    .get();

  const scores = snapshot.docs.map(doc => doc.data());

  const top100 = scores
    .sort((a, b) => b.score - a.score)
    .slice(0, 100);

  const batch = db.batch();
  const colRef = db
    .collection('rankings')
    .doc(`${mode}_${period}`)
    .collection(dateKey);

  top100.forEach(entry => {
    const docRef = colRef.doc(entry.userId);
    batch.set(docRef, {
      score: entry.score,
      timestamp: entry.timestamp,
      userId: entry.userId,
      userName: entry.userName,
    });
  });

  await batch.commit();
  console.log(`✔ ${mode}_${period} 集計完了 (${top100.length} 件)`);
}

// 実行
(async () => {
  const modes = ['level_1', 'level_2', 'level_3'];
  const periods = process.env.PERIODS.split(',');

  for (const mode of modes) {
    for (const period of periods) {
      await aggregateTopScores(mode, period);
    }
  }
})();
