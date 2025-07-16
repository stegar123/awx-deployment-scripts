# AWX Deployment Scripts

This repository contains scripts for deploying AWX (Ansible Web UI) on Kubernetes using the AWX Operator.

## Prerequisites

- Kubernetes cluster (1.19+)
- kubectl configured and connected to your cluster
- git installed
- Base64 encoded TLS certificate and key stored in environment variables:
  - `TENANTS_LB_CRT`: Base64 encoded certificate
  - `TENANTS_LB_KEY`: Base64 encoded private key

## Required Files

Ensure these files are present in your deployment directory:
- `nfs-server.yml` - NFS server configuration
- `linode-nfs-storage.yml` - Storage class configuration
- `awx-cr.yaml` - AWX Custom Resource definition

## Installation Steps

### 1. Clone AWX Repositories
```bash
bash 1_awx_clone.sh
```
This script:
- Clones the AWX Operator repository
- Checks out version 2.19.1 (stable release)
- Prepares the operator for deployment

### 2. Deploy AWX Infrastructure
```bash
bash 2_install_awx.sh
```
This script:
- Validates prerequisites and required files
- Installs NGINX Ingress Controller (v1.8.1)
- Installs NFS CSI drivers (v4.9.0)
- Creates AWX namespace and configures kubectl context
- Creates TLS secret for HTTPS access
- Deploys NFS server for persistent storage
- Deploys AWX Operator and creates AWX instance

## Post-Installation Verification

After successful deployment, verify the installation:

```bash
# Check AWX pods
kubectl get pods -n awx

# Check AWX service
kubectl get svc -n awx

# Check ingress
kubectl get ingress -n awx

# Monitor AWX instance status
kubectl get awx -n awx
```

## Troubleshooting

- **TLS Secret Error**: Ensure `TENANTS_LB_CRT` and `TENANTS_LB_KEY` environment variables are set
- **Missing Files**: Verify all required YAML files are present
- **Permissions**: Ensure kubectl has proper cluster access
- **Storage Issues**: Check NFS server deployment and storage class configuration
- **Timeout Issues**: AWX instance may take 5-10 minutes to fully initialize

## Version Information

- AWX Operator: v2.19.1
- NGINX Ingress: v1.8.1
- NFS CSI Driver: v4.9.0

## Support

For issues related to:
- AWX Operator: [GitHub Issues](https://github.com/ansible/awx-operator/issues)
- AWX: [GitHub Issues](https://github.com/ansible/awx/issues)