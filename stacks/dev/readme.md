# Development Environment Stacks

Stack configurations for the development environment.

## Available Stacks

### [us-west1.yaml](us-west1.yaml)
Development environment deployed to **us-west1** (Oregon) region.

**Configuration:**
- **Project**: smc-atmos-test-00
- **Region**: us-west1
- **Zone**: us-west1-a
- **VPC**: smc-atmos-vpc-00
- **Subnet**: smc-atmos-subnet-00 (10.0.0.0/24)
- **VM**: smc-atmos-vm-00 (e2-micro, Debian 12)

**Components Configured:**
- `gcp-project` - GCP project creation
- `vpc` - VPC network
- `subnet` - Subnet with flow logs
- `firewall` - HTTP and IAP SSH rules
- `vm` - GCE VM with Go web app

## Deployment

Deploy all components in order:
```bash
atmos terraform apply gcp-project -s dev
atmos terraform apply vpc -s dev
atmos terraform apply subnet -s dev
atmos terraform apply firewall -s dev
atmos terraform apply vm -s dev
```

Or use the Makefile:
```bash
make apply-all
```

## Viewing Configuration

See the full configuration for a component:
```bash
atmos describe component vpc -s dev
```

## Adding New Regions

To deploy to another region:
1. Copy `us-west1.yaml` to `us-east1.yaml`
2. Update region/zone values
3. Update resource names to include region identifier
4. Deploy with `-s dev-us-east1`
