Basic application, designed to return the IP address to the caller. Useful for a clean IP lookup for dyndns and the like.

Toolchain:
- python3
- uv
- fn
- terraform
- oci functions
- oci apigateway
## Hosting (Always Free)

Runs on one `VM.Standard.E2.1.Micro` (Always Free) behind the free Network Load Balancer.
`terraform/cloud-init.sh` installs Docker on first boot, logs into OCIR, and runs the image.
OCI Container Instances are not Always Free (they billed ~$23/month for 1 OCPU / 4 GB), so do not use them.
To ship a new image: `make build push tf-apply-update` (replaces the VM, which re-pulls on boot).
