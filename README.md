# 🏦 ai-bankapp-devops

A secure, slim, and resilient multi-tiered AI-powered Banking Application built with **Spring Boot**, **Java 21**, **MySQL**, **Maven**, and **Ollama (TinyLlama LLM)** — containerized using **Docker Compose** with production-grade best practices.

---

## 🧱 Tech Stack

| Layer | Technology |
|---|---|
| Backend | Spring Boot, Java 21 |
| Build Tool | Maven |
| Database | MySQL 8.0 |
| AI / LLM | Ollama (TinyLlama) |
| Containerization | Docker, Docker Compose |

---

## 🏗️ Project Architecture

```
ai-bankapp-devops/
├── src/                    # Spring Boot source code
├── Dockerfile              # Multi-stage secure Dockerfile
├── docker-compose.yml      # Multi-container orchestration
├── .env                    # Environment variables (gitignored)
├── .gitignore
└── pom.xml                 # Maven build file
```

---

## 🐳 Docker Services

| Container | Type | Description |
|---|---|---|
| `mysql` | Permanent | MySQL 8.0 database |
| `bankapp` | Permanent | Spring Boot application |
| `ollama` | Permanent | Ollama LLM server |
| `ollama-pull-model` | One-time Init | Pulls TinyLlama model on startup |

> ✅ `ollama-pull-model` exits with code `0` after pulling the model — this is **expected and normal behavior**.

---

## 🔐 Security Implementations

### 1. Multi-Stage Dockerfile
- **Stage 1 (Builder):** Uses `eclipse-temurin:21-jdk-jammy` to compile the app into a JAR using Maven
- **Stage 2 (Runtime):** Uses `eclipse-temurin:21-jre-jammy` — slim runtime only, no JDK, no source code, no build tools
- Reduces image size by ~70% and minimizes attack surface

### 2. Non-Root User
- Created a restricted system user `appuser` inside the container
- App runs as `appuser` — NOT as root
- Follows the **Principle of Least Privilege**

```dockerfile
RUN groupadd --system appgroup && useradd --system --gid appgroup appuser
USER appuser
```

### 3. Externalized Secrets via `.env`
- All passwords and sensitive config moved out of `docker-compose.yml`
- Stored in `.env` file which is **gitignored**
- Follows the **12-Factor App** methodology

---

## 💓 Health Checks

All services have health checks configured:

| Service | Health Check Command |
|---|---|
| `mysql` | `mysqladmin ping -h localhost` |
| `ollama` | `ollama list` |
| `bankapp` | `curl -f http://localhost:8080/actuator/health` |

---

## 🔗 Resilient Startup Order (depends_on)

```
ollama (healthy)
    ↓
ollama-pull-model (completed successfully)
    ↓
mysql (healthy)
    ↓
bankapp (starts)
```

Uses `condition: service_healthy` and `condition: service_completed_successfully` to ensure correct startup sequencing.

---

## 🔄 Restart Policies

| Service | Restart Policy |
|---|---|
| `mysql` | `unless-stopped` |
| `ollama` | `unless-stopped` |
| `bankapp` | `on-failure` |
| `ollama-pull-model` | `on-failure` |

---

## 📦 Resource Limits

`bankapp` has CPU and memory limits to prevent resource starvation:

```yaml
deploy:
  resources:
    limits:
      memory: 512m
      cpus: "0.5"
```

---

## 🚀 How to Run

### Prerequisites
- Docker Desktop installed
- Docker Compose installed

### Step 1: Clone the Repository
```bash
git clone https://github.com/your-username/ai-bankapp-devops.git
cd ai-bankapp-devops
```

### Step 2: Create `.env` File
```bash
touch .env
```

Add the following to `.env`:
```env
MYSQL_ROOT_PASSWORD=Test@123
MYSQL_PASSWORD=Test@123
MYSQL_USER=root
MYSQL_DATABASE=bankappdb
OLLAMA_URL=http://ollama:11434
```

### Step 3: Build and Start All Containers
```bash
docker compose up --build
```

> Use `--build` flag whenever `Dockerfile` is changed to rebuild the image.

### Step 4: Run in Background (Optional)
```bash
docker compose up --build -d
```

---

## ✅ Verify Everything is Working

### Check all containers are running:
```bash
docker ps -a
```

Expected output:
```
NAMES                STATUS
mysql                Up X minutes (healthy)
bankapp              Up X minutes (healthy)
ollama               Up X minutes (healthy)
ollama-pull-model    Exited (0) X minutes ago   ← ✅ Normal!
```

### Check app health:
```bash
curl http://localhost:8080/actuator/health
```
Expected: `{"status":"UP"}`

### Verify non-root user:
```bash
docker exec bankapp whoami
```
Expected: `appuser`

### Check health status of all containers:
```bash
docker inspect --format='{{.Name}} → {{.State.Health.Status}}' mysql bankapp ollama
```

### Check logs:
```bash
docker compose logs -f bankapp
docker logs ollama-pull-model
```

---

## 🛑 How to Stop

```bash
docker compose down
```

> This stops and removes containers but **keeps your volumes** (database data is safe).

---

## 🔑 When to Rebuild vs Restart

| Change Made | Command |
|---|---|
| `Dockerfile` changed | `docker compose up --build` |
| `docker-compose.yml` changed | `docker compose up -d` |
| `.env` changed | `docker compose up -d` |
| Both changed | `docker compose down` then `docker compose up --build` |

---

## 🧠 Key Concepts

### JDK vs JRE
- **JDK (Java Development Kit):** Full toolkit to compile and build Java apps — used in Stage 1
- **JRE (Java Runtime Environment):** Only runs Java apps — used in Stage 2 (slim!)
- **JAR (Java ARchive):** The packaged, compiled Spring Boot app that gets deployed

### Why `ollama-pull-model` Exits
- It is a **one-time init container** — its only job is to pull the `tinyllama` model
- `Exited (0)` = success ✅
- `Exited (1)` = failure ❌ (check logs with `docker logs ollama-pull-model`)

---

## 🌐 Access Points

| Service | URL |
|---|---|
| Bank App | http://localhost:8080 |
| Ollama LLM | http://localhost:11434 |
| MySQL | localhost:3306 |

---

## 📝 Interview Summary

> *"I implemented a multi-stage Docker build to reduce image size by ~70%, ran the app as a non-root user following the principle of least privilege, externalized secrets via `.env` following 12-Factor App principles, and used health checks with `depends_on` conditions to ensure resilient and ordered startup across MySQL, Ollama LLM, and the Spring Boot application."*

---

## 👤 Author

**Priti Mohikar**
