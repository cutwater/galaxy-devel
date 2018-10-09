.PHONY: build
build:
	ansible-playbook ansible/playbooks/build.yml

.PHONY: up
up:
	docker-compose -p galaxy_dev up -d

.PHONY: down
down:
	docker-compose -p galaxy_dev down
