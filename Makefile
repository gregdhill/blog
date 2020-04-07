.PHONY: theme
theme:
	git submodule update --init themes/tale

.PHONY: deploy
deploy:
	./deploy.sh