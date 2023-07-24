.PHONY: deploy

THEME=hermes

start:
	hexo server

deploy:
	hexo generate
	hexo deploy

css:
	npm run sass --prefix themes/${THEME}
