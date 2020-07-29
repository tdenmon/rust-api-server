build:
	docker-compose build
clean:
	rm -rf rust-api/target
up:
	docker-compose up -d
down:
	docker-compose down
solo-api:
	docker-compose up rust-api
