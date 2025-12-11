# Quick Reference Guide

## Common Commands

### Deploy All Infrastructure (in order)
```bash
atmos terraform apply gcp-project -s dev-us-west1
atmos terraform apply vpc -s dev-us-west1
atmos terraform apply subnet -s dev-us-west1
atmos terraform apply firewall -s dev-us-west1
atmos terraform apply vm -s dev-us-west1
```

### Destroy All Infrastructure (in reverse order)
```bash
atmos terraform destroy vm -s dev-us-west1
atmos terraform destroy firewall -s dev-us-west1
atmos terraform destroy subnet -s dev-us-west1
atmos terraform destroy vpc -s dev-us-west1
atmos terraform destroy gcp-project -s dev-us-west1
```

### Get VM External IP
```bash
gcloud compute instances describe smc-atmos-vm-00 \
  --zone=us-west1-a \
  --project=smc-atmos-test-00 \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

### SSH into VM
```bash
gcloud compute ssh smc-atmos-vm-00 \
  --zone=us-west1-a \
  --project=smc-atmos-test-00 \
  --tunnel-through-iap
```

### Check Web App Logs
```bash
# Via SSH, then:
sudo journalctl -u webapp.service -f
```

### View Startup Script Logs
```bash
# Via SSH, then:
sudo cat /var/log/startup-script.log
```

## Project Configuration

- **Project ID**: smc-atmos-test-00
- **Region**: us-west1 (Oregon)
- **Zone**: us-west1-a
- **VPC**: smc-atmos-vpc-00
- **Subnet**: smc-atmos-subnet-00 (10.0.0.0/24)
- **VM**: smc-atmos-vm-00 (e2-micro, Debian 12)

## Atmos File Locations

- **Main Config**: `atmos.yaml`
- **Components**: `components/terraform/`
- **Stacks**: `stacks/dev/us-west1.yaml`
- **Scripts**: `scripts/`
- **App Code**: `app/main.go`

## Web Application Endpoints

- **Main Page**: `http://<EXTERNAL_IP>/`
- **JSON API**: `http://<EXTERNAL_IP>/json`
- **Health Check**: `http://<EXTERNAL_IP>/health`

## Firewall Rules

- **HTTP**: Port 80 from 0.0.0.0/0 (internet)
- **SSH**: Port 22 from 35.235.240.0/20 (GCP IAP only)

## Atmos Benefits Demonstrated

1. **Separation of Concerns**: Components are reusable, stacks are environment-specific
2. **DRY Configuration**: Define once in component, configure in stack
3. **Clear Structure**: Easy to understand where everything lives
4. **One Thing Well**: Each component manages one resource type
5. **Easy Replication**: Copy stack file to deploy to new region/env
6. **Type Safety**: YAML configuration with clear variable definitions
7. **Terraform Integration**: Full Terraform power with better organization
