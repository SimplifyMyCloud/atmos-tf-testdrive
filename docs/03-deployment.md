# Deployment Guide

This guide walks you through deploying the infrastructure using Atmos.

## Prerequisites

Before deploying, ensure:
1. Atmos is installed (see [01-atmos-setup.md](01-atmos-setup.md))
2. GCP authentication is configured via ADC
3. You have necessary permissions in your GCP organization

## Important: Working Directory

**All commands in this guide must be run from the project root directory.**

```bash
# Navigate to the project root
cd /path/to/atmos-tf-testdrive

# Verify you're in the correct directory
ls atmos.yaml  # This file should exist
pwd            # Should show .../atmos-tf-testdrive
```

## Understanding Atmos Commands

Atmos uses a simple command structure:
```bash
atmos terraform <command> <component> -s <stack>
```

Where:
- `<command>`: Standard Terraform commands (plan, apply, destroy, etc.)
- `<component>`: The component name (from components/terraform/)
- `<stack>`: The stack name (from stacks/ directory structure)

For this project, our stack is: `dev`

## Deployment Order

Components must be deployed in order due to dependencies:

```
1. gcp-project  (creates the project)
2. vpc          (creates the network)
3. subnet       (creates the subnet in the network)
4. firewall     (creates firewall rules in the network)
5. vm           (creates the VM in the subnet)
```

## Step-by-Step Deployment

### 1. Create the GCP Project

```bash
# Plan
atmos terraform plan gcp-project -s dev

# Apply
atmos terraform apply gcp-project -s dev
```

This creates the project `smc-atmos-test-00` and enables required APIs.

**Important**: After creating the project, you may need to wait 1-2 minutes for APIs to fully enable before proceeding.

### 2. Create the VPC Network

```bash
# Plan
atmos terraform plan vpc -s dev

# Apply
atmos terraform apply vpc -s dev
```

This creates the VPC network `smc-atmos-vpc-00`.

### 3. Create the Subnet

```bash
# Plan
atmos terraform plan subnet -s dev

# Apply
atmos terraform apply subnet -s dev
```

This creates the subnet `smc-atmos-subnet-00` in us-west1 with flow logs enabled.

### 4. Create Firewall Rules

```bash
# Plan
atmos terraform plan firewall -s dev

# Apply
atmos terraform apply firewall -s dev
```

This creates:
- HTTP rule (allows port 80 from internet)
- IAP SSH rule (allows SSH via Identity-Aware Proxy)

### 5. Create the VM Instance

```bash
# Plan
atmos terraform plan vm -s dev

# Apply
atmos terraform apply vm -s dev
```

This creates the VM instance with the Go web application.

**Note**: The startup script will take 2-5 minutes to complete. The VM will:
1. Install system updates
2. Install Go
3. Build and deploy the web application
4. Start the application as a systemd service

## Verifying the Deployment

### Check VM Status

```bash
# Get VM details
gcloud compute instances describe smc-atmos-vm-00 \
  --zone=us-west1-a \
  --project=smc-atmos-test-00
```

### Get External IP

```bash
# Get external IP
gcloud compute instances describe smc-atmos-vm-00 \
  --zone=us-west1-a \
  --project=smc-atmos-test-00 \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

### Access the Web Application

Once you have the external IP:
```bash
# Main page (web interface)
curl http://<EXTERNAL_IP>/

# JSON metadata endpoint
curl http://<EXTERNAL_IP>/json

# Health check
curl http://<EXTERNAL_IP>/health
```

Or open in browser: `http://<EXTERNAL_IP>/`

### Check Startup Script Logs

SSH into the VM via IAP:
```bash
gcloud compute ssh smc-atmos-vm-00 \
  --zone=us-west1-a \
  --project=smc-atmos-test-00 \
  --tunnel-through-iap
```

Then check logs:
```bash
# Startup script log
sudo cat /var/log/startup-script.log

# Application logs
sudo journalctl -u webapp.service -f

# Or application log file
sudo tail -f /var/log/webapp.log
```

## Useful Atmos Commands

### View Component Configuration
```bash
atmos describe component <component-name> -s dev
```

Example:
```bash
atmos describe component vm -s dev
```

### List All Stacks
```bash
atmos list stacks
```

### List All Components
```bash
atmos list components
```

### Validate Stack Configuration
```bash
atmos validate stacks
```

### Show Terraform Outputs
```bash
atmos terraform output <component> -s dev
```

Example:
```bash
atmos terraform output vm -s dev
```

## Destroying Infrastructure

To tear down the infrastructure, reverse the deployment order:

```bash
# 1. Destroy VM
atmos terraform destroy vm -s dev

# 2. Destroy firewall rules
atmos terraform destroy firewall -s dev

# 3. Destroy subnet
atmos terraform destroy subnet -s dev

# 4. Destroy VPC
atmos terraform destroy vpc -s dev

# 5. Destroy project (optional - this deletes everything)
atmos terraform destroy gcp-project -s dev
```

**Warning**: Destroying the project will delete all resources within it.

## Troubleshooting

### API Not Enabled Error
If you get "API not enabled" errors, wait a few minutes after creating the project for APIs to fully activate.

### Permission Denied
Ensure your GCP account has the necessary roles:
- Project Creator
- Billing Account User
- Compute Admin (for VM operations)

### Startup Script Not Running
Check the serial console output:
```bash
gcloud compute instances get-serial-port-output smc-atmos-vm-00 \
  --zone=us-west1-a \
  --project=smc-atmos-test-00
```

### Web App Not Accessible
1. Check if VM has external IP
2. Verify firewall rules are created
3. Check if webapp service is running (via SSH + `systemctl status webapp`)
4. Check startup script logs

## Next Steps

- Modify stack configurations in `stacks/dev/us-west1.yaml`
- Create additional stacks for other regions/environments
- Extend components with additional variables
- Add more components for other GCP resources
