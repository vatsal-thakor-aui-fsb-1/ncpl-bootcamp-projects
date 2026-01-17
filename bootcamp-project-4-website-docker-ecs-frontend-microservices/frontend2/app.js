const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end('<h1>Frontend Service 2</h1>');
});

server.listen(3000, () => {
  console.log('Frontend2 running on port 3000');
});
