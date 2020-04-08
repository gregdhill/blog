.PHONY: theme
theme:
	git submodule update --init themes/nonagon

.PHONY: deploy
deploy:
	./deploy.sh