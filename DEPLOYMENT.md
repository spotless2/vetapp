# 🚀 Ghid de Deployment pentru Coolify

## Pași pentru a deploya aplicația în Coolify

### 1. Pregătire Git Repository

```bash
cd "e:\desktop folders\vet-app CS\vetapp"
git init
git add .
git commit -m "Pregătit pentru deployment Coolify"
git branch -M main
```

Apoi creează un repository pe GitHub și push:
```bash
git remote add origin https://github.com/username/vetapp.git
git push -u origin main
```

### 2. Configurare Coolify

1. **Conectează-te la Coolify** (portul 8000 pe serverul tău)

2. **Creează un nou Resource**:
   - Click pe **+ New**
   - Selectează **Docker Compose**
   - Conectează repository-ul tău GitHub
   - Setează **Build Path**: `/`
   - Setează **Docker Compose Path**: `/docker-compose.yml`

### 3. Variabile de Mediu în Coolify

Adaugă următoarele environment variables în Coolify:

```env
# Database Configuration
DB_HOST=db
DB_USER=vetuser
DB_PASSWORD=TauParolaSecure123!
DB_NAME=vet
DB_ROOT_PASSWORD=RootParolaSecure456!
DB_PORT=3307

# Backend Configuration
NODE_ENV=production
BACKEND_PORT=3000
HOST=0.0.0.0

# Frontend Configuration
FRONTEND_PORT=8080
API_URL=https://api-vetapp.your-domain.com
```

**⚠️ IMPORTANT**: 
- Schimbă `API_URL` cu URL-ul real pe care Coolify îl va genera pentru backend
- După primul deployment, Coolify va genera URL-uri pentru servicii
- Trebuie să actualizezi `API_URL` cu URL-ul backend-ului generat de Coolify

### 4. Configurare Ports & Domains

În Coolify, pentru fiecare serviciu:

**Backend Service (vetapp_backend)**:
- Port: 3000
- Domain: `api-vetapp.your-domain.com` (sau generează subdomain în Coolify)

**Frontend Service (vetapp_frontend)**:
- Port: 80 (intern în container)
- Domain: `vetapp.your-domain.com` (sau generează subdomain în Coolify)

**Database Service (vetapp_db)**:
- Port: 3306 (intern, nu expune public)
- Doar pentru comunicare internă între containere

### 5. Deploy

1. Click pe **Deploy** în Coolify
2. Monitorizează build logs
3. După build success, serviciile vor porni automat

### 6. Post-Deployment

1. **Verifică backend**: Vizitează `https://api-vetapp.your-domain.com/`
   - Ar trebui să vezi: "Hello World!"

2. **Actualizează API_URL**:
   - Dacă frontend nu se conectează la backend
   - Actualizează environment variable `API_URL` cu URL-ul corect
   - Redeploy aplicația

3. **Testează aplicația**:
   - Accesează frontend la `https://vetapp.your-domain.com`
   - Înregistrează un cont nou sau loghează-te cu `spotty/password`

### 7. Troubleshooting

**Problem: Frontend nu se conectează la backend**
```bash
# Verifică logs în Coolify pentru backend
# Asigură-te că API_URL este setat corect cu URL-ul backend-ului
# Exemplu: API_URL=https://api-vetapp.coolify-domain.com
```

**Problem: Database connection failed**
```bash
# Verifică că toate variabilele DB_* sunt setate corect
# Verifică că serviciul db este running în Coolify
# DB_HOST TREBUIE să fie "db" (numele serviciului din docker-compose)
```

**Problem: Build fails**
```bash
# Verifică build logs în Coolify
# Asigură-te că toate fișierele sunt pushed pe GitHub
# Verifică că docker-compose.yml este la root level
```

### 8. Invitarea Prietenilor

După deployment success:

1. **Trimite URL-ul frontend** prietenilor: `https://vetapp.your-domain.com`
2. **Creează conturi pentru ei** sau lasă-i să se înregistreze
3. **Asigură cabinete** pentru fiecare user (din admin panel)

### 9. Monitoring

În Coolify poți monitoriza:
- **Logs**: Vezi logs live pentru fiecare serviciu
- **Resources**: CPU, RAM usage
- **Status**: Health check pentru fiecare container

### 10. Update App

Când faci modificări:
```bash
git add .
git commit -m "Descriere modificări"
git push
```

Apoi în Coolify:
- Click pe **Redeploy** sau
- Activează **Auto Deploy on Push** pentru deploy automat

---

## 📋 Checklist Final

- [ ] Repository creat pe GitHub și cod pushed
- [ ] Resource Docker Compose creat în Coolify
- [ ] Toate environment variables configurate
- [ ] Domains/subdomains configurate pentru backend și frontend
- [ ] Prima deployment executată cu succes
- [ ] API_URL actualizat cu URL-ul real al backend-ului
- [ ] Aplicația testată și funcțională
- [ ] Prietenii pot accesa aplicația și se pot înregistra

---

## 🎉 Success!

Aplicația ta acum rulează în production pe Coolify!
Echipa ta poate accesa și testa aplicația pentru veterinar.
