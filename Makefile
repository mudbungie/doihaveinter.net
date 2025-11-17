.PHONY: test clean build run test-container tf-init tf-plan tf-apply push help

test:
	python3 test/test_get_ip.py

build:
	docker build -t get-ip:latest .
	docker tag get-ip:latest get-ip:0.0.1

push:
	docker tag get-ip:0.0.1 sjc.ocir.io/axkaehc4rqwi/get-ip:0.0.1
	docker push sjc.ocir.io/axkaehc4rqwi/get-ip:0.0.1

run:
	docker run --rm -p 8080:8080 get-ip:latest

test-container:
	@echo "Testing container endpoints..."
	@sleep 2
	@curl -s http://localhost:8080/health | python3 -m json.tool
	@echo ""
	@curl -s http://localhost:8080/ip | python3 -m json.tool

test-endpoint:
	@echo "Testing endpoint..."
	@curl -s $$(cd terraform && terraform output -raw endpoint_url)
	@echo

tf-init:
	cd terraform && terraform init

tf-plan:
	cd terraform && terraform plan

tf-apply:
	cd terraform && terraform apply

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete

help:
	@echo "Available targets:"
	@echo "  test           - Run Python unit tests"
	@echo "  build          - Build Docker image"
	@echo "  push           - Push image to OCIR"
	@echo "  run            - Run container locally on port 8080"
	@echo "  test-container - Test running container endpoints"
	@echo "  test-endpoint  - Test deployed endpoint"
	@echo "  tf-init        - Initialize Terraform"
	@echo "  tf-plan        - Plan Terraform changes"
	@echo "  tf-apply       - Apply Terraform changes"
	@echo "  clean          - Remove Python cache files"
	@echo "  help           - Show this help message"
