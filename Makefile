.PHONY: theme
theme:
	git submodule update --init themes/nonagon

.PHONY: deploy
deploy:
	./deploy.sh

.PHONY: ipfs
ipfs:
	hugo
	ipfs add -r public
	rm -rf public