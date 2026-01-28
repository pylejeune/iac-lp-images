/**
 * PM2 Ecosystem Configuration
 * Configuration pour gérer l'application Node.js avec PM2
 * Ce fichier sera monté dans /home/appuser/app/ecosystem.config.js
 */
module.exports = {
  apps: [
    {
      name: 'app',
      script: './server.js', // ou './index.js', './app.js', etc.
      instances: 1, // ou 'max' pour utiliser tous les CPU
      exec_mode: 'cluster', // 'fork' ou 'cluster'
      watch: false, // true en développement
      max_memory_restart: '500M',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: './logs/pm2-error.log',
      out_file: './logs/pm2-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      autorestart: true,
      max_restarts: 10,
      min_uptime: '10s',
      // Options avancées
      kill_timeout: 5000,
      wait_ready: false,
      listen_timeout: 10000
    }
  ]
};
