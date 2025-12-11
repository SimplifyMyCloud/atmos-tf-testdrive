# Makefile for Atmos + Terraform GCP Test Drive
# Simplifies common deployment operations

.PHONY: help plan-all apply-all destroy-all plan apply destroy status

STACK := dev-us-west1

help:
	@echo "Atmos + Terraform GCP Test Drive - Available Commands:"
	@echo ""
	@echo "  make plan-all      - Plan all components in order"
	@echo "  make apply-all     - Deploy all components in order"
	@echo "  make destroy-all   - Destroy all components in reverse order"
	@echo ""
	@echo "  make plan          - Plan specific component (use COMPONENT=name)"
	@echo "  make apply         - Apply specific component (use COMPONENT=name)"
	@echo "  make destroy       - Destroy specific component (use COMPONENT=name)"
	@echo ""
	@echo "  make status        - Show infrastructure status"
	@echo "  make get-ip        - Get VM external IP"
	@echo "  make ssh           - SSH into VM via IAP"
	@echo "  make logs          - View VM startup logs"
	@echo ""
	@echo "Examples:"
	@echo "  make apply COMPONENT=vpc"
	@echo "  make destroy COMPONENT=vm"
	@echo ""

# Plan all components in order
plan-all:
	@echo "Planning all components..."
	atmos terraform plan gcp-project -s $(STACK)
	atmos terraform plan vpc -s $(STACK)
	atmos terraform plan subnet -s $(STACK)
	atmos terraform plan firewall -s $(STACK)
	atmos terraform plan vm -s $(STACK)

# Deploy all components in order
apply-all:
	@echo "Deploying all components in order..."
	@echo "Step 1/5: Creating GCP Project..."
	atmos terraform apply gcp-project -s $(STACK) -auto-approve
	@echo "Waiting for APIs to enable..."
	@sleep 30
	@echo "Step 2/5: Creating VPC Network..."
	atmos terraform apply vpc -s $(STACK) -auto-approve
	@echo "Step 3/5: Creating Subnet..."
	atmos terraform apply subnet -s $(STACK) -auto-approve
	@echo "Step 4/5: Creating Firewall Rules..."
	atmos terraform apply firewall -s $(STACK) -auto-approve
	@echo "Step 5/5: Creating VM Instance..."
	atmos terraform apply vm -s $(STACK) -auto-approve
	@echo ""
	@echo "Deployment complete! Waiting for VM startup script to finish (2-5 minutes)..."
	@echo "Get external IP with: make get-ip"

# Destroy all components in reverse order
destroy-all:
	@echo "Destroying all components in reverse order..."
	@echo "Step 1/5: Destroying VM..."
	atmos terraform destroy vm -s $(STACK) -auto-approve
	@echo "Step 2/5: Destroying Firewall Rules..."
	atmos terraform destroy firewall -s $(STACK) -auto-approve
	@echo "Step 3/5: Destroying Subnet..."
	atmos terraform destroy subnet -s $(STACK) -auto-approve
	@echo "Step 4/5: Destroying VPC..."
	atmos terraform destroy vpc -s $(STACK) -auto-approve
	@echo "Step 5/5: Destroying GCP Project..."
	atmos terraform destroy gcp-project -s $(STACK) -auto-approve
	@echo "All resources destroyed!"

# Plan specific component
plan:
ifndef COMPONENT
	@echo "Error: Please specify COMPONENT=<name>"
	@echo "Available components: gcp-project, vpc, subnet, firewall, vm"
	@exit 1
endif
	atmos terraform plan $(COMPONENT) -s $(STACK)

# Apply specific component
apply:
ifndef COMPONENT
	@echo "Error: Please specify COMPONENT=<name>"
	@echo "Available components: gcp-project, vpc, subnet, firewall, vm"
	@exit 1
endif
	atmos terraform apply $(COMPONENT) -s $(STACK)

# Destroy specific component
destroy:
ifndef COMPONENT
	@echo "Error: Please specify COMPONENT=<name>"
	@echo "Available components: gcp-project, vpc, subnet, firewall, vm"
	@exit 1
endif
	atmos terraform destroy $(COMPONENT) -s $(STACK)

# Show infrastructure status
status:
	@echo "=== Infrastructure Status ==="
	@echo ""
	@echo "Checking GCP Project..."
	@gcloud projects describe smc-atmos-test-00 --format="value(name,projectId,lifecycleState)" 2>/dev/null || echo "Project not found"
	@echo ""
	@echo "Checking VPC..."
	@gcloud compute networks describe smc-atmos-vpc-00 --project=smc-atmos-test-00 --format="value(name)" 2>/dev/null || echo "VPC not found"
	@echo ""
	@echo "Checking Subnet..."
	@gcloud compute networks subnets describe smc-atmos-subnet-00 --region=us-west1 --project=smc-atmos-test-00 --format="value(name,ipCidrRange)" 2>/dev/null || echo "Subnet not found"
	@echo ""
	@echo "Checking VM..."
	@gcloud compute instances describe smc-atmos-vm-00 --zone=us-west1-a --project=smc-atmos-test-00 --format="value(name,status)" 2>/dev/null || echo "VM not found"

# Get VM external IP
get-ip:
	@echo "Getting VM external IP..."
	@gcloud compute instances describe smc-atmos-vm-00 \
		--zone=us-west1-a \
		--project=smc-atmos-test-00 \
		--format='get(networkInterfaces[0].accessConfigs[0].natIP)' 2>/dev/null || echo "VM not found or no external IP"

# SSH into VM
ssh:
	@echo "Connecting to VM via IAP..."
	@gcloud compute ssh smc-atmos-vm-00 \
		--zone=us-west1-a \
		--project=smc-atmos-test-00 \
		--tunnel-through-iap

# View VM logs
logs:
	@echo "Fetching startup script logs..."
	@gcloud compute instances get-serial-port-output smc-atmos-vm-00 \
		--zone=us-west1-a \
		--project=smc-atmos-test-00 \
		2>/dev/null || echo "VM not found or no logs available yet"

# List all Atmos components
list-components:
	@atmos list components

# List all Atmos stacks
list-stacks:
	@atmos list stacks

# Validate Atmos configuration
validate:
	@atmos validate stacks
