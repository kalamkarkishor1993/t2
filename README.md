# t2 - Terraform AWS Infrastructure with GitHub OIDC

This repository contains Terraform configurations for AWS infrastructure deployment and GitHub Actions CI/CD integration using OpenID Connect (OIDC) authentication.

## Architecture Overview

### What is OIDC?

OpenID Connect (OIDC) is a secure authentication protocol that allows GitHub Actions workflows to authenticate to AWS without storing long-lived access keys or secrets. Instead, GitHub Actions obtains short-lived credentials by exchanging a OIDC token for temporary AWS credentials.

**Benefits:**
- ✅ No hardcoded AWS credentials in GitHub Secrets
- ✅ Short-lived credentials (15 minutes default)
- ✅ Better audit trail and compliance
- ✅ Automatic credential rotation
- ✅ Reduced attack surface

### OIDC Setup Components

The infrastructure includes:

1. **GitHub OIDC Provider** (`aws_iam_openid_connect_provider`)
   - Trusts GitHub's OIDC token issuer (token.actions.githubusercontent.com)
   - Configured with GitHub's official thumbprint for token validation

2. **IAM Role for GitHub Actions** (`aws_iam_role`)
   - Can be assumed only by workflows from your specific repository and branch
   - Trust policy restricts assumptions to: `repo:kalamkarkishor1993/t2:ref:refs/heads/main`

3. **IAM Policy** (`aws_iam_role_policy`)
   - Grants permissions for Terraform operations (EC2, IAM, S3, DynamoDB, RDS)
   - Scoped to the resources needed for your infrastructure

## Project Structure

```
.
├── provider.tf          # AWS provider and account ID data source
├── oidc.tf              # GitHub OIDC provider and IAM role setup
├── main.tf              # Infrastructure resources (VPC, subnet, security group, etc.)
├── variable.tf          # All variable definitions
├── terraform.tfvar      # Variable values
└── README.md            # This file
```

## Prerequisites

Before deploying, ensure you have:

1. **AWS Account Access**
   - AWS credentials configured (via AWS CLI, environment variables, or IAM role)
   - Sufficient permissions to create IAM roles and OIDC providers

2. **Terraform Installed**
   ```bash
   terraform version  # Should be >= 1.0
   ```

3. **GitHub Repository**
   - Repository: `kalamkarkishor1993/t2`
   - Branch: `main`
   - Must have GitHub Actions enabled

## Deployment Steps

### Step 1: Deploy OIDC Infrastructure

```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply changes to create OIDC provider and IAM role
terraform apply
```

After deployment, Terraform will output:
- `github_actions_role_arn` - Use this in GitHub Actions workflows
- `aws_account_id` - Your AWS account ID
- `aws_region` - The AWS region configured

### Step 2: Configure GitHub Actions Workflow

Create `.github/workflows/terraform-deploy.yml`:

```yaml
name: Deploy Infrastructure

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

permissions:
  id-token: write  # Required for OIDC token
  contents: read

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      - name: Configure AWS Credentials via OIDC
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::<ACCOUNT_ID>:role/TerraformGitHubRole
          aws-region: ap-south-1

      - name: Terraform Format Check
        run: terraform fmt -check

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan -out=tfplan

      - name: Terraform Apply (on main branch only)
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -auto-approve tfplan
```

**Replace `<ACCOUNT_ID>` with your AWS account ID** from the Terraform outputs.

### Step 3: Verify OIDC Setup

Test the workflow by pushing code to the `main` branch or creating a pull request:

```bash
git add .
git commit -m "Add GitHub OIDC authentication setup"
git push origin main
```

Monitor the GitHub Actions workflow to ensure it:
1. ✅ Successfully assumes the IAM role
2. ✅ Authenticates to AWS without stored credentials
3. ✅ Plans and applies Terraform changes

## Verifying the Setup

### Check AWS Resources

```bash
# List OIDC providers
aws iam list-open-id-connect-providers

# View IAM role
aws iam get-role --role-name TerraformGitHubRole

# View role trust policy
aws iam get-role-policy --role-name TerraformGitHubRole --policy-name TerraformPolicy
```

### Check GitHub Workflow Logs

1. Go to your GitHub repository
2. Navigate to **Actions** tab
3. View workflow runs and logs
4. Look for successful role assumption: `aws sts assume-role-with-web-identity`

## Security Considerations

### ✅ Current Security Best Practices

- **Branch-restricted**: Role can only be assumed from `main` branch
- **Repo-specific**: Role is restricted to this specific repository
- **Short-lived credentials**: AWS STS provides 15-minute session tokens
- **No stored secrets**: No AWS keys stored in GitHub Secrets

### 🔒 Additional Hardening (Optional)

1. **More restrictive permissions**: Modify the inline policy in `oidc.tf` to grant only required actions:
   ```hcl
   actions = [
     "ec2:DescribeInstances",
     "ec2:RunInstances",
     "s3:GetObject",
     "s3:PutObject",
   ]
   ```

2. **Multiple branches**: To allow other branches (develop, staging), update the trust policy:
   ```hcl
   values = [
     "repo:${var.github_repo_owner}/${var.github_repo_name}:ref:refs/heads/main",
     "repo:${var.github_repo_owner}/${var.github_repo_name}:ref:refs/heads/develop",
   ]
   ```

3. **Audit logging**: Enable CloudTrail to audit all role assumptions and API calls

## Troubleshooting

### "User: arn:aws:iam::... is not authorized to perform: iam:..."

**Issue**: GitHub Actions workflow doesn't have permission to perform AWS actions.
**Solution**: Check the IAM policy in `oidc.tf` and ensure required actions are included.

### "Invalid JWT" or token validation errors

**Issue**: OIDC token validation failed.
**Solution**: Verify the thumbprint in `oidc.tf` is correct: `6938fd4d98bab03faadb97b34396831e3780aea1`

### GitHub Actions can't find AWS credentials

**Issue**: `configure-aws-credentials` action fails to assume role.
**Solution**: 
1. Ensure `id-token: write` permission is set in workflow
2. Verify role ARN is correct in workflow file
3. Check branch name matches the trust policy

## References

- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS OIDC Provider Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [Terraform AWS OIDC Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider)
- [GitHub Actions AWS Credentials Action](https://github.com/aws-actions/configure-aws-credentials)

## Variables

See [variable.tf](variable.tf) for all configurable variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `ap-south-1` |
| `github_repo_owner` | GitHub repository owner | `kalamkarkishor1993` |
| `github_repo_name` | GitHub repository name | `t2` |
| `github_branch` | Allowed GitHub branch | `main` |
| `iam_role_name` | IAM role name | `TerraformGitHubRole` |
| `iam_policy_name` | IAM policy name | `TerraformPolicy` |

## License

This project is provided as-is for educational and operational purposes.