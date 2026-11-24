.PHONY: lint test build evals

lint:
	ruff check src tests evals

test:
	pytest -q tests

build:
	mkdir -p dist
	python -m compileall -q src
	cp -r src dist/

evals:
	pytest -q evals
