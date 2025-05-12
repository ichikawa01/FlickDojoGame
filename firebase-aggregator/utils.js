function getDateKey(period, date = new Date()) {
    const pad = (n) => n.toString().padStart(2, '0');
    const y = date.getFullYear();
    const m = pad(date.getMonth() + 1);
    const d = pad(date.getDate());
  
    if (period === 'daily') return `${y}${m}${d}`;
    if (period === 'weekly') {
      const monday = new Date(date);
      monday.setDate(date.getDate() - ((date.getDay() + 6) % 7)); // 月曜に調整
      return `${monday.getFullYear()}${pad(monday.getMonth() + 1)}${pad(monday.getDate())}`;
    }
    if (period === 'monthly') return `${y}${m}`;
    if (period === 'total') return 'total';
    return '';
  }
  
  function getStartDate(period, now = new Date()) {
    const d = new Date(now);
    if (period === 'daily') return new Date(d.setHours(0, 0, 0, 0));
    if (period === 'weekly') return new Date(d.setDate(d.getDate() - ((d.getDay() + 6) % 7)));
    if (period === 'monthly') return new Date(d.getFullYear(), d.getMonth(), 1);
    if (period === 'total') return new Date('2000-01-01');
  }
  
  module.exports = {
    getDateKey,
    getStartDate
  };
  