# Environment Management Guide

Winger supports 3 isolated environment modes:

| Environment | Config File | Bundle ID | App Name | Logging |
| :--- | :--- | :--- | :--- | :--- |
| **Development** | `.env.development` | `co.winger.app.dev` | Winger Dev | Enabled |
| **Staging** | `.env.staging` | `co.winger.app.staging` | Winger Staging | Enabled |
| **Production** | `.env.production` | `co.winger.app` | Winger | Disabled |

## Security Policy

- `.env.example` contains non-sensitive key templates and is committed to Git.
- Specific `.env.*` files contain public client tokens (`SUPABASE_ANON_KEY`) appropriate for public apps.
- **SERVER SECRETS MUST NEVER BE COMMITTED OR EMBEDDED IN FLUTTER CODE**.
