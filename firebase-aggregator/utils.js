function toJST(date) {
    return new Date(date.getTime() + 9 * 60 * 60 * 1000); // UTC → JST (+9時間)
  }
  
  function getDateKey(period, date = new Date()) {
    const jst = toJST(date); // 🔁 JSTに変換
    const pad = (n) => n.toString().padStart(2, '0');
    const y = jst.getFullYear();
    const m = pad(jst.getMonth() + 1);
    const d = pad(jst.getDate());
  
    if (period === 'daily') return `${y}${m}${d}`;
  
    if (period === 'weekly') {
      const weekday = jst.getDay(); // JSTでの曜日
      const offset = weekday === 0 ? -6 : 1 - weekday; // 日曜は -6、他は月曜へ
      const monday = new Date(jst);
      monday.setDate(jst.getDate() + offset);
      const my = monday.getFullYear();
      const mm = pad(monday.getMonth() + 1);
      const md = pad(monday.getDate());
      return `${my}${mm}${md}`;
    }
  
    if (period === 'monthly') return `${y}${m}`;
    if (period === 'total') return 'total';
    return '';
  }
  
  function getStartDate(period, date = new Date()) {
    const jst = toJST(date); // 🔁 JSTに変換
  
    if (period === 'daily') {
      return new Date(Date.UTC(jst.getFullYear(), jst.getMonth(), jst.getDate(), 0, 0, 0));
    }
  
    if (period === 'weekly') {
      const weekday = jst.getDay();
      const offset = weekday === 0 ? -6 : 1 - weekday;
      const monday = new Date(jst);
      monday.setDate(jst.getDate() + offset);
      return new Date(Date.UTC(monday.getFullYear(), monday.getMonth(), monday.getDate(), 0, 0, 0));
    }
  
    if (period === 'monthly') {
      return new Date(Date.UTC(jst.getFullYear(), jst.getMonth(), 1, 0, 0, 0));
    }
  
    if (period === 'total') {
      return new Date('2000-01-01T00:00:00Z');
    }
  }
  
  module.exports = {
    getDateKey,
    getStartDate
  };
  