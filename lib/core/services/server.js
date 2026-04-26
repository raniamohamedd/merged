const http = require('http');
const socketIo = require('socket.io');

// إنشاء السيرفر
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello World');
});

// ربط socket.io مع السيرفر
const io = socketIo(server);

// استماع لحدث الاتصال
io.on('connection', (socket) => {
  console.log('عميل متصل!');

  // استقبال الرسائل
  socket.on('sendMessage', (data) => {
    console.log('رسالة جديدة:', data.message);

    // إرسال الرسالة إلى العميل الآخر
    socket.broadcast.emit('newMessage', data.message);
  });

  // عند قطع الاتصال
  socket.on('disconnect', () => {
    console.log('عميل منفصل!');
  });
});

// تشغيل السيرفر على المنفذ 3000
server.listen(3000, () => {
  console.log('السيرفر يعمل على http://localhost:3000');
});