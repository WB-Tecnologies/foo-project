VENV_PATH := $(HOME)/venv/bin
PROJ_NAME := foo

runserver:
	$(VENV_PATH)/python manage.py runserver 0.0.0.0:8000

start:
	mkdir -p var
	$(VENV_PATH)/gunicorn --preload --pid var/gunicorn.pid \
		-D -b 127.0.0.1:8000 $(PROJ_NAME).wsgi:application

stop:
	kill `cat var/gunicorn.pid` || true

restart: stop start

pep8:
	$(VENV_PATH)/pep8 --exclude=*migrations*,*settings_local.py* \
		--max-line-length=119 --show-source  $(PROJ_NAME)/

pyflakes:
	$(VENV_PATH)/pylama --skip=*migrations* -l pyflakes $(PROJ_NAME)/

lint: pep8 pyflakes

test:
	$(VENV_PATH)/python manage.py test -v 2 --noinput

cover_test:
	$(VENV_PATH)/coverage run --source=$(PROJ_NAME) manage.py test -v 2 --noinput

cover_report:
	$(VENV_PATH)/coverage report -m
	$(VENV_PATH)/coverage html
	$(VENV_PATH)/coverage-badge > htmlcov/coverage.svg

ci_test: cover_test cover_report lint

wheel_install:
	$(VENV_PATH)/pip install --no-index -f wheels/ -r requirements.txt

