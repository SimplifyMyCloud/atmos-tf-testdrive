# Stacks

Stack configurations define **what to deploy where**. Each stack is a YAML file that references components and provides environment-specific variable values.

## Directory Structure

Stacks are organized by environment:

```
stacks/
└── dev/              # Development environment
    └── us-west1.yaml # Oregon region configuration
```

## Stack Files

### [dev/us-west1.yaml](dev/us-west1.yaml)
Development environment configuration for the us-west1 (Oregon) region. Defines all infrastructure components with their specific settings.

## How Stacks Work

A stack file:
1. **References components** from `components/terraform/`
2. **Provides variable values** for each component
3. **Defines metadata** like component inheritance
4. **Configures the environment** (dev, staging, prod)

Example stack structure:
```yaml
components:
  terraform:
    vpc:
      metadata:
        component: vpc
      vars:
        project_id: "my-project"
        network_name: "my-vpc"
```

## Using Stacks

Deploy a component using a stack:
```bash
atmos terraform apply <component> -s <stack-name>
```

Example:
```bash
atmos terraform apply vpc -s dev
```

## Stack Naming Convention

Stack names follow the pattern: `{environment}-{region}`
- `dev` - Development in Oregon
- `prod-us-east1` - Production in South Carolina
- `staging-europe-west1` - Staging in Belgium

## Creating New Stacks

To add a new environment or region:

1. Copy an existing stack file
2. Modify the variable values (region, zone, resource names)
3. Deploy using the new stack name

Example:
```bash
cp dev/us-west1.yaml dev/us-east1.yaml
# Edit dev/us-east1.yaml
atmos terraform apply vpc -s dev-us-east1
```

## Benefits

- **DRY Principle**: Define infrastructure once in components, configure here
- **Environment Isolation**: Each stack is independent
- **Easy Replication**: Copy and modify for new environments
- **Clear Configuration**: YAML is human-readable
- **Version Control**: Stack configs are committed to git
