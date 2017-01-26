SHELL := /bin/bash
CURRENT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all: clean setup test

clean:
	@echo "Clean"
	rm -rf .py27

setup:
	@echo "Setup"
	virtualenv .py27
	.py27/bin/pip install -r requirements.txt

test:
	@echo "Run Tests"
	.py27/bin/pybot test.robot

test-phantomjs:
	@echo "Run Tests"
	.py27/bin/pybot --variable BROWSER:phantomjs test.robot
