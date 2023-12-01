FROM openjdk:17

WORKDIR /app

ARG JAR=/target/*.jar

COPY ${JAR} app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]

EXPOSE 8080
