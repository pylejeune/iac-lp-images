module.exports = ({ env }) => {
  // En production, ADMIN_JWT_SECRET doit être défini (ex. variable d'environnement).
  // En développement, fallback pour éviter l'erreur si .env.local n'est pas encore configuré.
  const adminJwtSecret = env('ADMIN_JWT_SECRET');
  const isDev = env('NODE_ENV', 'development') === 'development';
  const authSecret = adminJwtSecret || (isDev ? 'dev-admin-jwt-secret-change-in-production' : null);

  /*
  if (!authSecret) {
    throw new Error(
      'ADMIN_JWT_SECRET manquant. Définissez la variable d\'environnement ADMIN_JWT_SECRET (ex: openssl rand -base64 32). ' +
      'Voir .env.example et https://docs.strapi.io/developer-docs/latest/setup-deployment-guides/configurations/optional/environment.html'
    );
  }
*/
  return {
  auth: {
    secret: authSecret,
  },
  apiToken: {
    salt: env('API_TOKEN_SALT'),
  },
  transfer: {
    token: {
      salt: env('TRANSFER_TOKEN_SALT'),
    },
  },
  flags: {
    nps: env.bool('FLAG_NPS', true),
    promoteEE: env.bool('FLAG_PROMOTE_EE', true),
  },
  };
};
