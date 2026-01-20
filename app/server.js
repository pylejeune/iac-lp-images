/**
 * Serveur Express simple pour démonstration
 */
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Route de santé
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Route principale
app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Docker!',
    nodeVersion: process.version,
    platform: process.platform,
    env: process.env.NODE_ENV || 'development'
  });
});

// Route API
app.get('/api/info', (req, res) => {
  res.json({
    app: 'docker-app',
    version: '1.0.0',
    node: process.version,
    memory: process.memoryUsage(),
    uptime: process.uptime()
  });
});

// Démarrer le serveur
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`Node version: ${process.version}`);
});
