SCRIPT_NAME = ip_latlong.py

.PHONY: all clean doc docker lint reqs setup


reqs:
	pipreqs .

setup: requirements.txt
	pip install -r requirements.txt

docker:
	@echo "Not yet ready"

doc:
	doxygen doxy.config
lint:
	flake8 --config .flake8

clean:
	rm -f __pycache__

