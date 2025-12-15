# Architecture Overview

## Infrastructure Components

### 1. GCP Project (`gcp-project` component)
- Creates the GCP project: `smc-atmos-test-00`
- Associates with billing account
- Links to organization
- Enables required APIs

### 2. VPC Network (`vpc` component)
- Name: `smc-atmos-vpc-00`
- Auto-create subnets: disabled (manual control)
- Routing mode: REGIONAL
- Delete default routes on creation: false

### 3. Subnet (`subnet` component)
- Name: `smc-atmos-subnet-00`
- Region: us-west1
- IP CIDR range: 10.0.0.0/24
- Private Google Access: enabled
- Flow logs: enabled (for verbose logging)

### 4. Firewall Rules (`firewall` component)

#### HTTP Rule
- Name: `allow-http`
- Direction: INGRESS
- Source ranges: `0.0.0.0/0` (internet)
- Target: VMs with tag `http-server`
- Ports: TCP/80
- Purpose: Allow web traffic to the application

#### IAP SSH Rule
- Name: `allow-iap-ssh`
- Direction: INGRESS
- Source ranges: `35.235.240.0/20` (GCP IAP range)
- Target: All VMs in network
- Ports: TCP/22
- Purpose: Secure SSH access via Identity-Aware Proxy

### 5. GCE VM Instance (`vm` component)
- Name: `smc-atmos-vm-00`
- Zone: us-west1-a
- Machine type: e2-micro
- Boot disk: Debian 12
- Network tags: `http-server`
- Metadata startup script: Installs and runs Go web app
- Scopes: Cloud-platform (for metadata access)

## Application Architecture

### GoLang Web Application
Simple HTTP server that:
- Listens on port 80
- Displays VM metadata from GCP Metadata API
- Shows: instance name, zone, project, machine type, internal/external IPs

### Deployment Flow
1. VM boots with Debian 12
2. Startup script executes:
   - Updates system packages
   - Installs Go
   - Downloads application code
   - Compiles and runs Go application
3. Application starts on port 80
4. Accessible via external IP

## Security Design

### SSH Access
- No direct SSH on port 22 from internet
- SSH only via GCP Identity-Aware Proxy (IAP)
- Command: `gcloud compute ssh <vm-name> --zone us-west1-a --tunnel-through-iap`

### HTTP Access
- Port 80 open to internet (0.0.0.0/0)
- For demo purposes only
- Production would use HTTPS with Load Balancer

## Logging

All resources configured with verbose logging:
- VPC Flow Logs enabled on subnet
- VM system logs captured
- Firewall rule logs enabled

## Resource Dependencies

```
GCP Project
    ↓
VPC Network
    ↓
Subnet
    ↓
├─→ Firewall Rules
└─→ VM Instance
```

Terraform will handle dependency ordering automatically, but Atmos allows us to deploy components in stages if needed.

## Atmos Stack Structure

The `stacks/dev/us-west1.yaml` file orchestrates all components:
- References each component
- Provides component-specific variables
- Establishes dependencies between components
- Makes it easy to replicate in other regions/environments
