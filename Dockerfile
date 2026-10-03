FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
# Utilisation d'un joker pour parer à toute variation de nom, en excluant le "original-"
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
