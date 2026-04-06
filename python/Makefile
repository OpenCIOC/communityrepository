update-deps:
	python -m pip install -U pip pip-tools
	pip-compile --allow-unsafe -v -U requirements.in
	pip-compile --allow-unsafe -U requirements-dev.in
	pip-sync requirements-dev.txt

compile-deps:
	python -m pip install -U pip pip-tools
	pip-compile --allow-unsafe requirements.in
	pip-compile --allow-unsafe requirements-dev.in
	pip-sync requirements-dev.txt
