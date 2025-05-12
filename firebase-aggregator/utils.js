function toJST(date) {
    return new Date(date.getTime() + 9 * 60 * 60 * 1000); // UTC → JST (+9時間)
}

function getDateKey(period, date = new Date()) {
    const pad = (n) => n.toString().padStart(2, '0');
    const y = date.getUTCFullYear();
    const m = pad(date.getUTCMonth() + 1);
    const d = pad(date.getUTCDate());
  
    if (period === 'daily') return `${y}${m}${d}`;
  
    if (period === 'weekly') {
      const weekday = date.getUTCDay();
      const offset = weekday === 0 ? -6 : 1 - weekday;
      const monday = new Date(date);
      monday.setUTCDate(date.getUTCDate() + offset);
      return `${monday.getUTCFullYear()}${pad(monday.getUTCMonth() + 1)}${pad(monday.getUTCDate())}`;
    }
  
    if (period === 'monthly') return `${y}${m}`;
    if (period === 'total') return 'total';
    return '';
  }
  

  function getStartDate(period, date = new Date()) {
    const utc = new Date(date); // そのまま UTC
  
    if (period === 'daily') {
      return new Date(utc.getFullYear(), utc.getMonth(), utc.getDate(), 0, 0, 0);
    }
  
    if (period === 'weekly') {
      const weekday = utc.getDay();
      const offset = weekday === 0 ? -6 : 1 - weekday;
      const monday = new Date(utc);
      monday.setDate(utc.getDate() + offset);
      return new Date(monday.getFullYear(), monday.getMonth(), monday.getDate(), 0, 0, 0);
    }
  
    if (period === 'monthly') {
      return new Date(utc.getFullYear(), utc.getMonth(), 1, 0, 0, 0);
    }
  
    if (period === 'total') {
      return new Date('2000-01-01T00:00:00Z');
    }
  }
  

module.exports = {
getDateKey,
getStartDate
};

