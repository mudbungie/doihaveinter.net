.PHONY: test clean build tf-init tf-plan tf-apply help

test:
	python3 test/test_get_ip.py

build:
	docker build -t get-ip:latest .

tf-init:
	cd terraform && terraform init

tf-plan:
	cd terraform && terraform plan

tf-apply:
	cd terraform && terraform apply

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

help:
	@echo "Available targets:"
	@echo "  test     - Run tests"
	@echo "  build    - Build Docker image"
	@echo "  tf-init  - Initialize Terraform"
	@echo "  tf-plan  - Plan Terraform changes"
	@echo "  tf-apply - Apply Terraform changes"
	@echo "  clean    - Remove Python cache files"
	@echo "  help     - Show this help message"
