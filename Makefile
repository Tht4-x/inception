all:
	mkdir -p /home/dancel/data/db
	mkdir -p /home/dancel/data/wordpress
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down -v
	rm -rf /home/dancel/data/db
	rm -rf /home/dancel/data/wordpress

fclean: clean
	docker system prune -af

re: fclean all

.PHONY: all down clean fclean re
