.PHONY: test clean build help

test:
	python3 test/test_get_ip.py

build:
	docker build -t get-ip:latest .

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

help:
	@echo "Available targets:"
	@echo "  test  - Run tests"
	@echo "  build - Build Docker image"
	@echo "  clean - Remove Python cache files"
	@echo "  help  - Show this help message"
