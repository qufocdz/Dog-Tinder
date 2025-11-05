Dog-Tinder simple backend

This is a minimal Node.js + Express backend to support registration and login for the Dog-Tinder Flutter app.

Setup

1. Copy `.env.example` to `.env` and fill `MONGODB_URI` with your MongoDB connection string.

2. Install dependencies:

   npm install

3. Run in development mode (auto-restart):

   npm run dev

Endpoints

- POST /api/register
  - multipart/form-data
  - fields: dogName, email, password, birthdate (yyyy-mm-dd), description
  - file: dogImage

- POST /api/login
  - x-www-form-urlencoded or application/json
  - fields: email, password

Uploaded images are saved into `server/uploads/` and are served under `/uploads/<filename>`.

Security note

This is a simple example for local development. For production you should:
- Use HTTPS
- Validate and sanitize all inputs
- Store files in object storage (S3) or GridFS with proper access controls
- Implement rate limiting, strong password rules, email verification, and secure session/auth tokens (JWT or similar)
