# Scripts

Helper scripts for VM initialization and other automation tasks.

## Available Scripts

### [vm-startup.sh](vm-startup.sh)
VM startup script that runs when the GCE instance boots.

**What it does:**
1. Updates system packages (apt-get update/upgrade)
2. Installs required packages (wget, git, curl)
3. Downloads and installs Go 1.21.5
4. Creates application directory at `/opt/webapp`
5. Creates the Go web application (`main.go`)
6. Builds the Go binary
7. Creates systemd service (`webapp.service`)
8. Starts the web application on port 80

**Logs:**
- Startup script output: `/var/log/startup-script.log`
- Application logs: `/var/log/webapp.log`
- Application errors: `/var/log/webapp-error.log`

**Systemd Service:**
- Name: `webapp.service`
- Auto-starts on boot
- Auto-restarts on failure

**Execution Time:**
The startup script takes approximately 2-5 minutes to complete, depending on:
- System package updates
- Go installation download speed
- Application compilation time

## Usage

The startup script is embedded in the stack configuration (`stacks/dev/us-west1.yaml`) and automatically runs when the VM is created.

You can also view/test the script manually:
```bash
# View the script
cat scripts/vm-startup.sh

# Test locally (not recommended - designed for GCE)
# bash scripts/vm-startup.sh
```

## Monitoring Script Execution

### Check if script completed
```bash
gcloud compute instances get-serial-port-output smc-atmos-vm-00 \
  --zone=us-west1-a \
  --project=smc-atmos-test-00
```

### View startup log (via SSH)
```bash
sudo cat /var/log/startup-script.log
```

### Check web app service status
```bash
sudo systemctl status webapp.service
```

## Modifying the Script

To modify the startup script:
1. Edit `scripts/vm-startup.sh` (for reference)
2. Update the `startup_script` variable in `stacks/dev/us-west1.yaml`
3. Redeploy the VM: `atmos terraform apply vm -s dev`

**Note:** The script in `stacks/dev/us-west1.yaml` is the authoritative version that gets deployed. The file in `scripts/` is for reference and testing.
