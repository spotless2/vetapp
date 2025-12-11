# VetApp - Veterinary Management System

## 🚀 Quick Start with Docker

### Prerequisites
- Docker and Docker Compose installed
- Git

### Local Development with Docker

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd vetapp
```

2. **Copy environment variables**
```bash
cp .env.example .env
```

3. **Start all services**
```bash
docker-compose up -d
```

4. **Access the application**
- Frontend: http://localhost:8080
- Backend API: http://localhost:3000
- MySQL: localhost:3307

### Stopping the application
```bash
docker-compose down
```

## 🔧 Coolify Deployment

### Step 1: Prepare Repository
1. Create a new repository on GitHub
2. Push your code:
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```

### Step 2: Configure Coolify

1. **Create New Project** in Coolify
2. **Add New Resource** → Docker Compose
3. **Connect GitHub Repository**
4. **Set docker-compose.yml location**: `/docker-compose.yml`

### Step 3: Environment Variables

Add these environment variables in Coolify:

```env
# Database
DB_HOST=db
DB_USER=vetuser
DB_PASSWORD=<strong-password>
DB_NAME=vet
DB_ROOT_PASSWORD=<strong-root-password>
DB_PORT=3307

# Backend
NODE_ENV=production
BACKEND_PORT=3000
HOST=0.0.0.0

# Frontend
FRONTEND_PORT=8080
API_URL=https://your-backend-domain.com
```

**Important**: Replace `your-backend-domain.com` with your actual Coolify backend URL!

### Step 4: Deploy

1. Click **Deploy** in Coolify
2. Wait for build to complete
3. Access your application via the provided Coolify URLs

## 📦 Project Structure

```
vetapp/
├── backend/              # Node.js Express API
│   ├── controllers/      # Business logic
│   ├── models/          # Database models (Sequelize)
│   ├── routes/          # API routes
│   ├── uploads/         # User uploaded files
│   ├── Dockerfile       # Backend container
│   └── package.json
├── frontend/            # Flutter Web App
│   ├── lib/
│   │   ├── config/      # API configuration
│   │   └── *.dart       # Pages and widgets
│   ├── Dockerfile       # Frontend container (Flutter + nginx)
│   ├── nginx.conf       # Web server config
│   └── pubspec.yaml
├── docker-compose.yml   # Multi-container setup
├── .env.example         # Environment template
└── README.md
```

## 🛠️ Development

### Backend (Node.js)
```bash
cd backend
npm install
npm start
```

### Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_URL=http://localhost:3000
```

## 📝 API Endpoints

- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `GET /users/:id` - Get user details
- `GET /clients` - List clients
- `GET /pets` - List pets
- `GET /visits` - List visits
- `GET /appointments` - List appointments
- `GET /products` - List inventory products

## 🔒 Security Notes

- Change default passwords in production
- Use strong database credentials
- Enable HTTPS in production (Coolify handles this automatically)
- Keep `.env` file secure and never commit it

## 🐛 Troubleshooting

### Backend won't connect to database
- Verify `DB_HOST=db` (Docker service name)
- Check database credentials in `.env`
- Wait for MySQL to be ready (healthcheck in docker-compose)

### Frontend can't reach backend
- Verify `API_URL` is set correctly
- Check CORS is enabled in backend
- Ensure both services are running

### Coolify deployment fails
- Check build logs in Coolify dashboard
- Verify environment variables are set
- Ensure docker-compose.yml is at repository root

## 👥 Default Login

After first deployment, register a new user or use:
- Username: `spotty`
- Password: `password`

## 📄 License

Private project for veterinary clinic management.
