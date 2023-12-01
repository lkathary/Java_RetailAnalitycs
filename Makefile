#Before 'build' make sure that the 'retail_analytics' database exists and check the properties in the "application.properties” file.

# For IDE add 'Environment variables':
# DB_URL=jdbc:postgresql://localhost:5432/retail_analytics?escapeSyntaxCallMode=callIfNoReturn;DB_USER=lordik;DB_PASSWORD=lordik

export DB_URL=jdbc:postgresql://localhost:5432/retail_analytics?escapeSyntaxCallMode=callIfNoReturn
export DB_USER=lordik
export DB_PASSWORD=lordik

all: build

build:
	./mvnw clean compile package -DskipTests

run:
	./mvnw spring-boot:run

docker: build
	docker-compose up --build
