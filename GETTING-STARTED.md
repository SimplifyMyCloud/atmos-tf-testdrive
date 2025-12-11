# Getting Started with Atmos Test Drive

Welcome to your Atmos + Terraform test drive on GCP! This guide will get you up and running quickly.

## What's Been Created

Your repository now contains a complete Atmos-based infrastructure-as-code setup:

### Components (Reusable Terraform Modules)
- **gcp-project**: Creates and configures GCP project
- **vpc**: Creates VPC network
- **subnet**: Creates subnet with flow logs
- **firewall**: Creates HTTP and IAP SSH firewall rules
- **vm**: Creates GCE VM instance with Go web app

### Stack Configuration
- **dev/us-west1.yaml**: Development environment configuration for Oregon region

### Documentation
- **00-overview.md**: Project overview and purpose
- **01-atmos-setup.md**: Installation and setup guide
- **02-architecture.md**: Detailed architecture
- **03-deployment.md**: Step-by-step deployment
- **04-quick-reference.md**: Quick command reference

### Application
- **app/main.go**: Go web application that displays VM metadata
- **scripts/vm-startup.sh**: VM initialization script

## Prerequisites Checklist

Before deploying, ensure you have:

- [ ] Atmos installed (`brew install cloudposse/tap/atmos` or `go install github.com/cloudposse/atmos@latest`)
- [ ] Terraform >= 1.0 installed
- [ ] GCP CLI installed and configured
- [ ] GCP authentication set up: `gcloud auth application-default login`
- [ ] Required GCP permissions (Project Creator, Billing Account User)

## Important: Working Directory

**All commands in this guide must be run from the project root directory** (`atmos-tf-testdrive/`).

```bash
# Navigate to the project root
cd /path/to/atmos-tf-testdrive

# Verify you're in the right place
ls atmos.yaml  # Should exist
```

## Quick Deploy (Using Makefile)

The easiest way to deploy everything:

```bash
# Deploy all infrastructure
make apply-all

# Wait 2-5 minutes for VM startup script to complete, then:
make get-ip

# Access the web app at http://<EXTERNAL_IP>/
```

To destroy everything:
```bash
make destroy-all
```

## Manual Deploy (Using Atmos Commands)

If you prefer to deploy step-by-step:

```bash
# 1. Create GCP Project
atmos terraform apply gcp-project -s dev

# Wait 30-60 seconds for APIs to enable

# 2. Create VPC
atmos terraform apply vpc -s dev

# 3. Create Subnet
atmos terraform apply subnet -s dev

# 4. Create Firewall Rules
atmos terraform apply firewall -s dev

# 5. Create VM
atmos terraform apply vm -s dev
```

## Verify Deployment

### Check Infrastructure Status
```bash
make status
```

### Get VM External IP
```bash
make get-ip
```

### Access the Web Application
Open your browser to: `http://<EXTERNAL_IP>/`

You should see a page displaying:
- Instance Name
- Instance ID
- Zone
- Project ID
- Machine Type
- Internal IP
- External IP
- Hostname

### Additional Endpoints
- **JSON API**: `http://<EXTERNAL_IP>/json`
- **Health Check**: `http://<EXTERNAL_IP>/health`

## Common Operations

### SSH into the VM
```bash
make ssh

# Or manually:
gcloud compute ssh smc-atmos-vm-00 \
  --zone=us-west1-a \
  --project=smc-atmos-test-00 \
  --tunnel-through-iap
```

### View Startup Logs
```bash
make logs

# Or via SSH:
make ssh
# Then once inside:
sudo cat /var/log/startup-script.log
```

### Check Web App Service
```bash
make ssh
# Then:
sudo systemctl status webapp.service
sudo journalctl -u webapp.service -f
```

### Deploy Individual Component
```bash
make apply COMPONENT=vm
make destroy COMPONENT=vm
```

## Understanding the Structure

### Components Directory
Each subdirectory in `components/terraform/` is a self-contained Terraform module:
- `main.tf` - Resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values

These are **reusable** and **environment-agnostic**.

### Stacks Directory
YAML files in `stacks/` define **what to deploy where**:
- Reference components
- Provide variable values
- Define environment-specific configuration

This is where you configure for different environments/regions.

## Customization Examples

### Change VM Machine Type
Edit `stacks/dev/us-west1.yaml`:
```yaml
vm:
  vars:
    machine_type: "e2-small"  # Change from e2-micro
```

Then redeploy:
```bash
atmos terraform apply vm -s dev
```

### Change Subnet CIDR
Edit `stacks/dev/us-west1.yaml`:
```yaml
subnet:
  vars:
    ip_cidr_range: "10.1.0.0/24"  # Change from 10.0.0.0/24
```

### Add New Region
1. Copy the stack file:
```bash
cp stacks/dev/us-west1.yaml stacks/dev/us-east1.yaml
```

2. Edit the new file to change:
   - Region: `us-west1` → `us-east1`
   - Zone: `us-west1-a` → `us-east1-b`
   - Resource names: Add region identifier

3. Deploy:
```bash
atmos terraform apply <component> -s dev-us-east1
```

## Troubleshooting

### "API not enabled" Error
Wait 1-2 minutes after creating the project for APIs to fully activate.

### Web App Not Accessible
1. Verify VM is running: `make status`
2. Check startup script completed: `make logs`
3. Verify firewall rules exist
4. SSH in and check service: `sudo systemctl status webapp.service`

### Permission Denied
Ensure your GCP account has:
- Project Creator role
- Billing Account User role
- Compute Admin role (for VM operations)

### Startup Script Issues
Check the serial console output:
```bash
gcloud compute instances get-serial-port-output smc-atmos-vm-00 \
  --zone=us-west1-a \
  --project=smc-atmos-test-00
```

## Next Steps

1. **Explore the Infrastructure**: SSH into the VM, check logs, explore the resources in GCP Console

2. **Modify the Web App**: Edit `app/main.go` and update the startup script in the stack

3. **Create a New Environment**: Copy and modify the stack file for a production environment

4. **Add More Components**: Create new components for Cloud SQL, Cloud Storage, etc.

5. **Learn Atmos Features**: Explore stack inheritance, imports, and workflows

6. **Read the Docs**: Deep dive into the comprehensive documentation in `docs/`

## Helpful Make Commands

```bash
make help              # Show all available commands
make apply-all         # Deploy everything
make destroy-all       # Destroy everything
make status            # Check infrastructure status
make get-ip            # Get VM external IP
make ssh               # SSH into VM
make logs              # View startup logs
make list-components   # List Atmos components
make list-stacks       # List Atmos stacks
make validate          # Validate Atmos configuration
```

## Resources

- **Atmos Documentation**: https://atmos.tools
- **Terraform Documentation**: https://terraform.io
- **GCP Documentation**: https://cloud.google.com/docs
- **Project Docs**: See `docs/` directory

## Support

For issues or questions:
- Check the troubleshooting section above
- Review detailed docs in `docs/`
- Consult CLAUDE.md for architecture details
- Review Atmos documentation at https://atmos.tools

---

Happy Infrastructure Coding! 🚀
