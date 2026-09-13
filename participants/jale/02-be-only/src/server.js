const express = require('express');
const app = express();
app.get('/', (_req, res) => res.send('<h1>This backend is working<br>Submission by Jale</h1>'));
app.get('/health', (_req, res) => res.json({ status: 'ok' }));
app.listen(3000, '0.0.0.0', () => console.log('Listening on 3000'));
