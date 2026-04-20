# STAGE 1: Build
FROM eclipse-temurin:21-jdk-jammy AS builder
WORKDIR /app
COPY . .
RUN chmod +x mvnw && ./mvnw clean package -DskipTests

# STAGE 2: Runtime (slim) 
FROM eclipse-temurin:21-jre-jammy AS runtime

# Security: run as non-root user
RUN groupadd --system appgroup && useradd --system --gid appgroup appuser

WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar

# Ownership to non-root user
RUN chown appuser:appgroup app.jar

USER appuser

EXPOSE 8080

# Health check at container level
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]