update-deps:
	python -m pip install -U pip pip-tools
	pip-compile -v -U requirements.in
	pip-compile -U requirements-dev.in
	pip-sync requirements-dev.txt

compile-deps:
	python -m pip install -U pip pip-tools
	pip-compile requirements.in
	pip-compile requirements-dev.in
	pip-sync requirements-dev.txt
