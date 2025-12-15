# Components

This directory contains all Atmos components for the project.

## Terraform Components

The `terraform/` subdirectory contains reusable Terraform modules that define infrastructure resources. Each component:

- Is **environment-agnostic** - no hardcoded values for specific environments
- **Does one thing well** - manages a single type of GCP resource
- Contains standard Terraform files: `main.tf`, `variables.tf`, `outputs.tf`
- Can be reused across multiple stacks/environments

## Available Components

- **[gcp-project](terraform/gcp-project/)** - Creates and configures GCP project
- **[vpc](terraform/vpc/)** - Creates VPC network
- **[subnet](terraform/subnet/)** - Creates subnet with flow logs
- **[firewall](terraform/firewall/)** - Creates firewall rules
- **[vm](terraform/vm/)** - Creates GCE VM instance

## How Components Work

Components are referenced by stacks (in `stacks/` directory). A stack provides the variable values and determines which components to deploy.

Example stack reference:
```yaml
components:
  terraform:
    vpc:
      vars:
        project_id: "my-project"
        network_name: "my-vpc"
```

This tells Atmos to use the `vpc` component with the specified variable values.
