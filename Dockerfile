FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
# Force la copie du gros JAR exécutable Spring Boot (il fait généralement plusieurs dizaines de Mo)
COPY target/EmployeeManagementSystem-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
