#Before 'build' make sure that the 'retail_analytics' database exists and check the properties in the "application.properties” file.

all: build

build:
	./mvnw clean compile package
run:
	./mvnw spring-boot:run
