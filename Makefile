build:
	docker-compose build
clean:
	rm -rf rust-api/target
up:
	docker-compose up -d postgres
	docker-compose up -d rust-api
down:
	docker-compose down
solo-api:
	docker-compose up -d rust-api
solo-db:
	docker-compose up -d postgres
ps:
	docker-compose ps
logs:
	docker-compose logs
