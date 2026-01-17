const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end('<h1>Frontend Service 1</h1>');
});

server.listen(3000, () => {
  console.log('Frontend1 running on port 3000');
});
