# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Atmos + Terraform test drive project demonstrating how Atmos simplifies Terraform infrastructure management on GCP. The project follows the principle of "do one thing well" with separate components for each GCP resource type.

**Environment**: Development/test environment prioritizing simplicity
**Cloud Provider**: Google Cloud Platform (GCP)
**Region**: us-west1 (Oregon)
**Project ID**: smc-atmos-test-00
**Organization ID**: 933250405420
**Billing Account**: 000000-000002-6D3BF8

## Architecture

The infrastructure consists of:
- GCP Project with enabled APIs
- VPC Network (custom, no auto-subnets)
- Subnet with flow logs enabled
- Firewall rules (HTTP from internet, SSH via IAP only)
- GCE VM (e2-micro, Debian 12) running a Go web application

## Working Directory

**All commands must be run from the project root directory** (`atmos-tf-testdrive/`).

```bash
cd /path/to/atmos-tf-testdrive
ls atmos.yaml  # Verify you're in the right place
```

## Key Commands

### Atmos Commands
```bash
# Deploy a component
atmos terraform apply <component> -s dev

# Plan changes
atmos terraform plan <component> -s dev

# Destroy a component
atmos terraform destroy <component> -s dev

# View component configuration
atmos describe component <component> -s dev

# List components
atmos list components

# Validate stacks
atmos validate stacks
```

### GCP Commands
```bash
# Get VM external IP
gcloud compute instances describe smc-atmos-vm-00 \
  --zone=us-west1-a --project=smc-atmos-test-00 \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

# SSH via IAP
gcloud compute ssh smc-atmos-vm-00 \
  --zone=us-west1-a --project=smc-atmos-test-00 \
  --tunnel-through-iap
```

### Deployment Order
Components must be deployed in this order due to dependencies:
1. `gcp-project` - Creates the GCP project
2. `vpc` - Creates VPC network
3. `subnet` - Creates subnet in the VPC
4. `firewall` - Creates firewall rules for the VPC
5. `vm` - Creates VM instance in the subnet

Reverse order for destruction.

## Directory Structure

```
components/terraform/    - Reusable Terraform components (one per GCP resource)
  ├── gcp-project/      - GCP project creation
  ├── vpc/              - VPC network
  ├── subnet/           - Subnet with flow logs
  ├── firewall/         - Firewall rules (HTTP + IAP SSH)
  └── vm/               - GCE VM instance
stacks/                 - Environment-specific configurations
  └── dev/us-west1.yaml - Dev environment stack for Oregon
scripts/                - Helper scripts
  └── vm-startup.sh     - VM startup script (also embedded in stack)
app/                    - Application source code
  └── main.go           - Go web app displaying VM metadata
docs/                   - Documentation
atmos.yaml             - Atmos configuration
```

## Atmos Architecture Principles

### Components (components/terraform/)
- Reusable Terraform modules
- Environment-agnostic
- Define WHAT can be created
- Each component does ONE thing well (UNIX philosophy)
- Contains: main.tf, variables.tf, outputs.tf

### Stacks (stacks/)
- Environment-specific configurations
- Reference components and provide variable values
- Define WHERE and HOW to deploy
- YAML format for readability
- Stack name pattern: `dev` (environment-region)

### Key Benefit
Components are reusable code, stacks are configuration. Change stack values to deploy same components to different environments/regions.

## Component Details

### gcp-project
- Creates GCP project and associates billing
- Enables required APIs: compute, logging, monitoring, IAP
- Location: `components/terraform/gcp-project/`

### vpc
- Creates custom VPC network
- No auto-created subnets (manual control)
- Regional routing mode
- Location: `components/terraform/vpc/`

### subnet
- Creates subnet in specified region
- CIDR: 10.0.0.0/24
- Flow logs enabled with full metadata (verbose logging)
- Private Google Access enabled
- Location: `components/terraform/subnet/`

### firewall
- Creates two firewall rules:
  1. HTTP: Allow port 80 from 0.0.0.0/0 to VMs with tag "http-server"
  2. IAP SSH: Allow port 22 from 35.235.240.0/20 (GCP IAP range)
- Logging enabled with full metadata
- Location: `components/terraform/firewall/`

### vm
- Creates e2-micro GCE instance
- Debian 12 boot disk
- Network tag: "http-server"
- Startup script embedded in stack YAML
- Service account with cloud-platform scope
- Location: `components/terraform/vm/`

## Go Web Application

**Location**: `app/main.go`
**Purpose**: Displays GCE instance metadata via web interface
**Endpoints**:
- `/` - HTML page with VM metadata
- `/json` - JSON API of VM metadata
- `/health` - Health check endpoint

**Deployment**: Via startup script that:
1. Installs Go 1.21.5
2. Creates app in /opt/webapp
3. Builds the Go binary
4. Deploys as systemd service "webapp.service"
5. Starts on port 80

## Logging

All resources configured with verbose logging:
- VPC flow logs: INTERVAL_5_SEC, 100% sampling, full metadata
- Firewall logs: Full metadata included
- VM logs: Serial console + systemd journal
- Application logs: /var/log/webapp.log and /var/log/webapp-error.log

## Common Modifications

### Change VM Machine Type
Edit `stacks/dev/us-west1.yaml`:
```yaml
components:
  terraform:
    vm:
      vars:
        machine_type: "e2-small"  # Change from e2-micro
```

### Add New Region
1. Copy `stacks/dev/us-west1.yaml` to `stacks/dev/us-east1.yaml`
2. Update region/zone variables
3. Update resource names to include region identifier
4. Deploy with `-s dev-us-east1`

### Modify Startup Script
Edit the `startup_script` variable in `stacks/dev/us-west1.yaml` under the `vm` component.

### Add New Component
1. Create directory: `components/terraform/<component-name>/`
2. Add main.tf, variables.tf, outputs.tf
3. Reference in stack: `stacks/dev/us-west1.yaml`

## Authentication

**Method**: Application Default Credentials (ADC)
**Setup**: `gcloud auth application-default login`
**Required Roles**:
- Project Creator
- Billing Account User
- Compute Admin

## Troubleshooting

### API Not Enabled
Wait 1-2 minutes after creating project for APIs to fully activate.

### Startup Script Issues
Check logs via:
1. Serial console: `gcloud compute instances get-serial-port-output smc-atmos-vm-00 --zone=us-west1-a --project=smc-atmos-test-00`
2. SSH in and check: `/var/log/startup-script.log`

### Web App Not Accessible
1. Verify external IP exists
2. Check firewall rules applied
3. SSH in and check: `sudo systemctl status webapp.service`

### Terraform State
Atmos manages Terraform state in `.terraform/` within each component directory. For production, configure remote state (GCS, S3, etc.).

## Documentation

See `docs/` directory:
- `00-overview.md` - Project overview
- `01-atmos-setup.md` - Atmos installation and setup
- `02-architecture.md` - Detailed architecture
- `03-deployment.md` - Step-by-step deployment guide
- `04-quick-reference.md` - Quick command reference

## Design Philosophy

1. **Simplicity First**: Dev environment quality, not production
2. **One Thing Well**: Each component manages single resource type
3. **Documentation**: Comprehensive docs in /docs
4. **Atmos Benefits**: Demonstrates separation of concerns, DRY principle
5. **Verbose Logging**: All resources configured for maximum observability
