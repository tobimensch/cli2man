.PHONY: clean docs

help:
	@echo "clean - remove all build, test, coverage and Python artifacts"
	@echo "docs - create necessary assets"
	@echo "sdist - create an sdist"
	@echo "release - create an sdist and upload"

docs:
	./cli2man ./cli2man -o auto --gzip

sdist:
	python setup.py sdist

release:
	python setup.py sdist upload --sign
