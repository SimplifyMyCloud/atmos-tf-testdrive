# Atmos + Terraform Test Drive on GCP

A demonstration project showcasing how [Atmos](https://atmos.tools) simplifies and organizes Terraform infrastructure management on Google Cloud Platform.

## What This Project Demonstrates

This test drive shows how Atmos provides:
- **Separation of Concerns**: Reusable components vs. environment-specific configurations
- **DRY Principle**: Define infrastructure once, configure per environment
- **Clear Organization**: Intuitive directory structure
- **UNIX Philosophy**: Each component does one thing well
- **Easy Replication**: Simple stack-based configuration for multiple environments

## What We're Building

A simple GCP infrastructure stack:
- **GCP Project**: smc-atmos-test-00
- **VPC Network**: smc-atmos-vpc-00 (custom, no auto-subnets)
- **Subnet**: smc-atmos-subnet-00 (10.0.0.0/24 in us-west1)
- **Firewall Rules**: HTTP (port 80) + IAP SSH access
- **GCE VM**: e2-micro Debian 12 instance running a Go web application
- **Web App**: Displays VM metadata via clean web interface

All resources configured with verbose logging for observability.

## Quick Start

### Prerequisites
- [Atmos](https://atmos.tools) installed
- [Terraform](https://terraform.io) >= 1.0
- [GCP CLI](https://cloud.google.com/sdk/docs/install) configured
- GCP authentication: `gcloud auth application-default login`

### Deploy

**Important**: All commands must be run from the project root directory.

```bash
# Navigate to project root
cd atmos-tf-testdrive

# Deploy infrastructure in order
atmos terraform apply gcp-project -s dev
atmos terraform apply vpc -s dev
atmos terraform apply subnet -s dev
atmos terraform apply firewall -s dev
atmos terraform apply vm -s dev

# Get the VM's external IP
gcloud compute instances describe smc-atmos-vm-00 \
  --zone=us-west1-a --project=smc-atmos-test-00 \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

# Access the web app at http://<EXTERNAL_IP>/
```

### Cleanup

```bash
# Destroy in reverse order
atmos terraform destroy vm -s dev
atmos terraform destroy firewall -s dev
atmos terraform destroy subnet -s dev
atmos terraform destroy vpc -s dev
atmos terraform destroy gcp-project -s dev
```

## Project Structure

```
├── components/terraform/   # Reusable Terraform components
│   ├── gcp-project/       # GCP project creation
│   ├── vpc/               # VPC network
│   ├── subnet/            # Subnet with flow logs
│   ├── firewall/          # Firewall rules
│   └── vm/                # GCE VM instance
├── stacks/                # Environment configurations
│   └── dev/us-west1.yaml  # Dev environment in Oregon
├── docs/                  # Comprehensive documentation
│   ├── 00-overview.md
│   ├── 01-atmos-setup.md
│   ├── 02-architecture.md
│   ├── 03-deployment.md
│   └── 04-quick-reference.md
├── app/                   # Go web application
│   └── main.go
├── scripts/               # Helper scripts
│   └── vm-startup.sh
├── atmos.yaml            # Atmos configuration
└── CLAUDE.md             # AI assistant guidance

```

## Documentation

Comprehensive documentation available in the `docs/` directory:
- **[Overview](docs/00-overview.md)** - Project purpose and benefits
- **[Atmos Setup](docs/01-atmos-setup.md)** - Installation and configuration
- **[Architecture](docs/02-architecture.md)** - Detailed architecture explanation
- **[Deployment](docs/03-deployment.md)** - Step-by-step deployment guide
- **[Quick Reference](docs/04-quick-reference.md)** - Common commands and info

## Key Features

### Atmos Organization
- **Components**: Reusable Terraform modules (one per GCP resource type)
- **Stacks**: YAML configurations defining what to deploy where
- **Clear Separation**: Infrastructure code vs. configuration

### Security
- SSH access only via GCP Identity-Aware Proxy (no public port 22)
- HTTP accessible for demo purposes (port 80)
- Minimal service account scopes

### Logging
- VPC flow logs with full metadata
- Firewall rule logging enabled
- VM system and application logs
- Serial console output available

### Web Application
Built with Go, the application:
- Displays VM metadata (instance name, zone, IPs, etc.)
- Provides JSON API endpoint (`/json`)
- Includes health check endpoint (`/health`)
- Auto-starts via systemd service

## Customization

### Change VM Size
Edit `stacks/dev/us-west1.yaml`:
```yaml
vm:
  vars:
    machine_type: "e2-small"  # Change from e2-micro
```

### Add New Region
1. Copy `stacks/dev/us-west1.yaml` to new region file
2. Update region/zone and resource names
3. Deploy with new stack name

### Modify Web App
Edit `app/main.go` and update the startup script in the stack configuration.

## Why Atmos?

Vanilla Terraform can become unwieldy as projects grow. Atmos tames the complexity by:

1. **Organizing Code**: Clear component/stack separation
2. **Reducing Duplication**: DRY configuration via inheritance
3. **Improving Readability**: YAML configs vs. HCL variables
4. **Enabling Reuse**: Deploy same components to multiple environments
5. **Simplifying Workflows**: Consistent command patterns

## License

MIT

## Contributing

This is a test drive project for learning purposes. Feel free to fork and experiment!
