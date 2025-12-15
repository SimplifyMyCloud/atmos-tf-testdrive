# Atmos Setup Guide

## Prerequisites

- Terraform >= 1.0
- Go >= 1.19 (for Atmos installation)
- GCP CLI (`gcloud`)
- GCP authentication configured

## Installing Atmos

### macOS (Homebrew)
```bash
brew install cloudposse/tap/atmos
```

### Using Go
```bash
go install github.com/cloudposse/atmos@latest
```

### Verify Installation
```bash
atmos version
```

## GCP Authentication Setup

This project uses Application Default Credentials (ADC). Ensure you're authenticated:

```bash
# Login with your GCP account
gcloud auth application-default login

# Verify authentication
gcloud auth list

# Set default project (optional, after project is created)
gcloud config set project smc-atmos-test-00
```

## Required GCP Permissions

Your account needs the following permissions at the organization level:
- `resourcemanager.projects.create`
- `billing.resourceAssociations.create`
- `resourcemanager.organizations.get`

Recommended roles:
- Project Creator
- Billing Account User

## Atmos Configuration

The `atmos.yaml` file at the root defines:
- Where components live (`components/terraform/`)
- Where stacks live (`stacks/`)
- Base paths and naming conventions

## Directory Structure Explained

### Components (`components/terraform/`)
Reusable Terraform modules that define infrastructure resources. Each component:
- Does ONE thing well (UNIX philosophy)
- Is environment-agnostic
- Contains standard Terraform files (main.tf, variables.tf, outputs.tf)

### Stacks (`stacks/`)
Environment-specific configurations that:
- Reference components
- Provide variable values
- Define what gets deployed where
- Use YAML format for easy reading

### Example
A component defines WHAT (e.g., a VPC), a stack defines WHERE and HOW (e.g., in us-west1 with specific CIDR).

## Next Steps

See [03-deployment.md](03-deployment.md) for deployment instructions.
