# Atmos + Terraform GCP Test Drive - Overview

## Project Purpose

This project demonstrates how Atmos simplifies Terraform management by providing a structured approach to organizing infrastructure code. This is a development/test environment focused on simplicity and learning.

## What We're Building

A simple GCP infrastructure stack consisting of:

- **GCP Project**: `smc-atmos-test-00`
- **Region**: `us-west1` (Oregon)
- **VPC Network**: `smc-atmos-vpc-00`
- **Subnet**: `smc-atmos-subnet-00` (in us-west1)
- **Firewall Rules**:
  - Allow HTTP (port 80) from internet
  - Allow IAP SSH access (no public port 22)
- **GCE VM**:
  - Machine type: e2-micro
  - OS: Debian 12
  - Runs a GoLang web application displaying VM metadata
- **Logging**: Verbose logging enabled on all resources

## GCP Configuration

- **Organization ID**: 933250405420
- **Billing Account**: 000000-000002-6D3BF8
- **Authentication**: Application Default Credentials (ADC)

## Key Benefits of Using Atmos

1. **Separation of Concerns**: Components (reusable Terraform modules) are separate from stacks (environment-specific configs)
2. **DRY Principle**: Define infrastructure once, configure per environment
3. **Clear Organization**: Easy to understand directory structure
4. **One Thing Well**: Each component manages a single GCP resource type
5. **Environment Management**: Simple stack-based configuration for different environments

## Directory Structure

```
atmos-tf-testdrive/
├── docs/                      # Documentation
├── components/terraform/      # Reusable Terraform components
│   ├── gcp-project/          # Creates GCP project
│   ├── vpc/                  # Creates VPC network
│   ├── subnet/               # Creates subnet
│   ├── firewall/             # Creates firewall rules
│   └── vm/                   # Creates GCE VM
├── stacks/dev/               # Dev environment configuration
├── scripts/                  # Helper scripts
├── app/                      # Application code
└── atmos.yaml               # Atmos configuration
```

## Next Steps

See the following documentation:
- [01-atmos-setup.md](01-atmos-setup.md) - How to install and configure Atmos
- [02-architecture.md](02-architecture.md) - Detailed architecture explanation
- [03-deployment.md](03-deployment.md) - How to deploy the infrastructure
