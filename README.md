# AWS Terraform Modules

Reusable Terraform modules for AWS infrastructure. The `example/` directory
contains demo root configurations, while consumers should reference a module
using this Git repository as the Terraform `source`.

## Use From Git

Use the module's subdirectory in the repository URL. Pin `ref` to a branch,
release tag, or commit. Release tags are recommended for repeatable
deployments because module updates can then be adopted intentionally.

```hcl
module "vpc" {
	source = "git::https://github.com/pratik-khot/aws-terraform-modules.git//modules/vpc?ref=v1.0.0"
}
```

The `v1.0.0` value is an example release tag. Replace it with a tag that exists
in this repository. Use `ref=main` only when testing the latest development
code.

To create a release, create and push a version tag after the changes are ready:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Use semantic version tags such as `v1.0.0` for the first release,
`v1.1.0` for compatible features, and `v2.0.0` for breaking changes.

The `../../modules/...` source paths shown in the files under `example/` are
only for running the demos from this repository. Replace them with the Git
source when copying a module block into another project.

## Requirements

- Terraform `>= 1.9.0`
- AWS provider `~> 6.0`
- AWS credentials configured for the target account

Initialize and apply a configuration from its root directory:

```bash
terraform init
terraform plan
terraform apply
```

## Available Modules

| Module | Status | Purpose |
| --- | --- | --- |
| `modules/vpc` | Implemented | VPC, public/private subnets, NAT gateway, route tables, and optional public security group |
| `modules/eks` | Implemented | EKS cluster, standard managed node group, Auto Mode support, addons, pod identity, and optional Fargate/LBC roles |
| `modules/ec2` | Implemented | EC2 instance, root volume, optional EBS data volumes, and volume attachments |

## VPC Module

The VPC module creates one public and one private subnet per selected
availability zone. Private subnet traffic uses a NAT gateway. It also enables
VPC Flow Logs and sends them to a CloudWatch log group. The default security
group, which allows HTTP, HTTPS, and SSH from the internet, can be disabled
with `default_sg_required = false`.

```hcl
module "vpc" {
	source = "git::https://github.com/pratik-khot/aws-terraform-modules.git//modules/vpc?ref=v1.0.0"

	region                = "us-east-1"
	vpc_cidr              = "10.0.0.0/16"
	az_count              = 3
	subnet_newbits        = 8
	nat_availability_mode = "zonal" # or "regional"
	environment           = "dev"
	project_name          = "demo"
	project_owner         = "platform-team"
	default_sg_required   = false
	log_group_retention_in_days = 365
	log_group_kms_key_arn       = null
}

output "vpc_id" {
	value = module.vpc.vpc_id
}

output "private_subnet_ids" {
	value = module.vpc.private_subnet_ids
}
```

VPC outputs:

- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
- `public_subnet_map` (availability zone to subnet ID)
- `private_subnet_map` (availability zone to subnet ID)

VPC Flow Logs settings:

- `log_group_retention_in_days` controls CloudWatch log retention and defaults
	to `365` days.
- `log_group_kms_key_arn` optionally encrypts the CloudWatch log group.

## EKS Module

Pass the private subnet IDs from the VPC module to create an EKS cluster. The
cluster enables API, audit, authenticator, controller manager, and scheduler
control-plane logs. The default `eks_mode` is `standard`; set it to `auto` to
enable EKS Auto Mode.

```hcl
module "eks" {
	source = "git::https://github.com/pratik-khot/aws-terraform-modules.git//modules/eks?ref=v1.0.0"

	cluster_name    = "demo-eks"
	cluster_version = "1.36"
	region          = "us-east-1"
	subnet_ids      = module.vpc.private_subnet_ids

	auth_mode                 = "API_AND_CONFIG_MAP"
	creator_admin_permissions = true
	eks_mode                  = "standard" # or "auto"
	enable_fargate            = false
	fargate_namespace         = "default"
	create_lbc_role           = false
}
```

The `addons` input is a map. Its keys are addon names and an optional
`version` can be supplied for each addon. Defaults are selected automatically
for the chosen EKS mode.

```hcl
module "eks" {
	source     = "git::https://github.com/pratik-khot/aws-terraform-modules.git//modules/eks?ref=v1.0.0"
	# ...required cluster arguments...

	addons = {
		coredns = {
			version = "addon-version"
		}
	}
}
```

The EKS module exports `cluster_connection`, a command that updates the local
kubeconfig for the cluster:

```bash
terraform output -raw cluster_connection
```

## EC2 Module

The EC2 module creates one instance. `data_volume_specs` is a map keyed by a
logical volume name; each entry creates and attaches one EBS volume.

```hcl
module "ec2" {
	source = "git::https://github.com/pratik-khot/aws-terraform-modules.git//modules/ec2?ref=v1.0.0"

	ami_id             = "ami-0123456789abcdef0"
	instance_type      = "t3.micro"
	subnet_id          = module.vpc.private_subnet_ids[0]
	sg_ids             = [aws_security_group.app.id]
	app_name           = "demo-app"
	env                = "dev"
	iam_instance_profile = aws_iam_instance_profile.app.name

	root_volume_specs = {
		size                  = 30
		type                  = "gp3"
		delete_on_termination = true
		encrypted             = true
	}

	data_volume_specs = {
		app_data = {
			size        = 50
			device_name = "/dev/sdf"
			encrypted   = true
		}
	}
}
```

EC2 outputs are `instance_id`, `instance_private_ip`, `instance_public_ip`,
and `attached_ebs_volume_ids`.

## Examples

Working root configurations are available under [`example/`](example/):

- [`example/vpc/`](example/vpc/) creates the VPC module.
- [`example/eks/`](example/eks/) creates the EKS module and reads VPC subnet IDs
	from Terraform remote state.
