PIP-SYNC = pip-sync --pip-args "--require-hash"
PIP-COMPILE = pip-compile --generate-hashes --allow-unsafe

install-dev-deps: dev-deps
	$(PIP-SYNC) requirements.txt dev-requirements.txt

install-deps: deps
	$(PIP-SYNC) requirements.txt

deps:
	pip install --upgrade pip pip-tools
	$(PIP-COMPILE) requirements.in

dev-deps: deps
	$(PIP-COMPILE) dev-requirements.in

fetchdb:
	scp borshev.com:/srv/pmdaily/storage/pmdaily.sqlite storage/
	cd src && ./manage.py anonymize_db

server:
	cd src && ./manage.py migrate && ./manage.py runserver

worker:
	cd src && celery -A app worker -E --purge

lint:
	cd src && ./manage.py makemigrations --check --no-input --dry-run
	flake8 src
	cd src && mypy

test:
	cd src && pytest -n 4 --ff -x --cov-report=xml --cov=. -m 'not single_thread'
	cd src && pytest --ff -x --cov-report=xml --cov=. --cov-append -m 'single_thread'
	cd src && pytest --dead-fixtures
