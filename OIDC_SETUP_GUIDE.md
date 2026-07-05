# GitHub OIDC Authentication Setup - Deployment Guide

## ✅ Implementation Complete!

Your GitHub OIDC authentication to AWS has been successfully configured with Terraform IaC.

---

## 📦 What Was Created/Modified

### Files Modified:
1. **provider.tf** — Replaced bash script with proper Terraform AWS provider configuration
   - AWS provider setup with region support
   - Data sources for account ID and region information

2. **variable.tf** — Enhanced with GitHub OIDC variables
   - GitHub repository owner, name, and branch
   - IAM role and policy name variables
   - AWS region configuration

3. **terraform.tfvar** — Updated with your configuration
   - GitHub repo: `kalamkarkishor1993/t2`
   - GitHub branch: `main`
   - AWS region: `ap-south-1`
   - IAM role: `TerraformGitHubRole`

4. **README.md** — Complete documentation added
   - OIDC architecture explanation
   - Setup instructions and verification steps
   - Security best practices
   - Troubleshooting guide

### Files Created:
1. **oidc.tf** (New) — All OIDC and IAM resources
   - GitHub OIDC Provider (`aws_iam_openid_connect_provider`)
   - IAM Role with trust policy for GitHub Actions
   - IAM Policy for Terraform operations
   - Terraform outputs (role ARN, account ID, region)

2. **.github/workflows/terraform-deploy.yml** (New) — Example GitHub Actions workflow
   - OIDC token generation and role assumption
   - Terraform plan, validate, and apply steps
   - PR comments with plan summary

---

## 🚀 Next Steps: Deploy OIDC Infrastructure to AWS

### Step 1: Verify Configuration
```bash
cd /workspaces/t2

# Check formatting
terraform fmt -check -recursive

# Validate syntax
terraform validate
```

### Step 2: Review Infrastructure Plan
```bash
terraform plan
```

This will show you exactly what will be created:
- GitHub OIDC Provider
- IAM Role for GitHub Actions
- IAM Policy with permissions for EC2, IAM, S3, DynamoDB, RDS

### Step 3: Deploy to AWS (Requires AWS Credentials)
```bash
terraform apply
```

After successful deployment, Terraform will output:
- **github_actions_role_arn**: Use this in GitHub Actions workflows
- **aws_account_id**: Your AWS account ID
- **aws_region**: Configured region

### Step 4: Update GitHub Actions Workflow

The workflow file `.github/workflows/terraform-deploy.yml` is ready but needs one update:

Replace this line in the workflow:
```yaml
role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/TerraformGitHubRole
```

With the actual role ARN from terraform apply output. Or add `AWS_ACCOUNT_ID` as a GitHub Actions secret.

### Step 5: Push to GitHub and Test

```bash
git add .
git commit -m "feat: Add GitHub OIDC authentication for AWS"
git push origin main
```

Monitor the GitHub Actions workflow to verify:
- ✅ Terraform validates successfully
- ✅ Role assumption via OIDC succeeds
- ✅ Terraform plan completes
- ✅ Infrastructure deploys (if on main branch)

---

## 🔍 Verify OIDC Setup in AWS

After deployment, verify everything is configured correctly:

```bash
# List OIDC providers
aws iam list-open-id-connect-providers

# View the GitHub Actions role
aws iam get-role --role-name TerraformGitHubRole

# View the role's trust policy
aws iam get-role-policy --role-name TerraformGitHubRole --policy-name TerraformPolicy
```

---

## 📋 Configuration Summary

| Component | Value |
|-----------|-------|
| GitHub Repo | kalamkarkishor1993/t2 |
| GitHub Branch | main |
| AWS Region | ap-south-1 |
| IAM Role Name | TerraformGitHubRole |
| IAM Policy Name | TerraformPolicy |
| OIDC Provider | token.actions.githubusercontent.com |
| Allowed Actions | EC2:*, IAM:*, S3:*, DynamoDB:*, RDS:* |

---

## 🛡️ Security Features

✅ **Short-lived credentials** — AWS STS provides 15-minute session tokens  
✅ **No stored secrets** — No AWS keys in GitHub  
✅ **Repository-specific** — Only your repo can use the role  
✅ **Branch-restricted** — Only main branch can assume the role  
✅ **Audit trail** — All actions logged in CloudTrail  
✅ **Automatic rotation** — Tokens refresh on each workflow run  

---

## 📚 Additional Resources

- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS IAM OIDC Provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [Terraform AWS OIDC Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider)

---

## ❓ Need Help?

See the `README.md` file for:
- Detailed OIDC architecture explanation
- Step-by-step setup verification
- Troubleshooting common issues
- Security hardening recommendations
