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

  const path = `${mode}_${period}`;
  const colRef = db.collection('rankings').doc(path).collection(dateKey);

  const snapshot = await colRef.get();

  console.log(`📂 Firestoreパス: rankings/${path}/${dateKey}`);
  console.log(`📈 ドキュメント数: ${snapshot.docs.length}`);

  const scores = snapshot.docs
  .filter(doc => doc.id !== "top")
  .map(doc => {
    const data = doc.data();
    const ts = data.timestamp;
    const tsMs = ts?.toMillis?.();
    const startMs = start.getTime();

    console.log(`📄 userId: ${data.userId}`);
    console.log(`🔸 timestamp: ${ts?.toDate().toISOString?.()}`);
    console.log(`🔸 toMillis(): ${tsMs}`);
    console.log(`🔹 start JST: ${start.toISOString()} → getTime(): ${startMs}`);
    console.log(`🔍 有効？ ${tsMs >= startMs}`);
    return {
      userId: data.userId,
      score: data.score,
      timestamp: ts
    };
})
    .filter(doc => {
        if (!doc.score || !doc.timestamp) return false;
        return doc.timestamp.toMillis() >= start.getTime(); // 正確に比較
  });

  console.log(`🎯 有効スコア件数（>= ${start.toISOString()}）: ${scores.length}`);

  const top100 = scores
    .sort((a, b) => b.score - a.score)
    .slice(0, 100);

  const topDocRef = db
    .collection('rankings')
    .doc(path)
    .collection(dateKey)
    .doc('top');

  await topDocRef.set({
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    top: top100
  });

  console.log(`${path} の集計完了：${top100.length}件`);
}

// 実行部
(async () => {
  const modes = ['level_1', 'level_2', 'level_3'];
  const periods = process.env.PERIODS.split(',');

  for (const mode of modes) {
    for (const period of periods) {
      await aggregateTopScores(mode, period);
    }
  }
})();
