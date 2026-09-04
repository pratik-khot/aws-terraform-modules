# AWS Terraform Modules

Reusable Terraform modules for foundational AWS networking, compute, and
Kubernetes infrastructure. The repository contains independent modules for a
VPC, an EC2 instance with EBS storage, and an Amazon EKS cluster. The modules
are designed to be composed: create the VPC first, then pass its private subnet
IDs to EKS or EC2 workloads.

## Features

- Multi-AZ VPCs with public and private subnets, internet/NAT routing, and VPC Flow Logs.
- Optional public security group with HTTP, HTTPS, and SSH ingress.
- EKS standard managed node groups or EKS Auto Mode.
- EKS managed add-ons with automatic compatible-version discovery and pod identity for CNI and EBS CSI.
- Optional EKS Fargate profile and AWS Load Balancer Controller IAM resources.
- EC2 instances with configurable networking, monitoring, termination protection, root disks, and attached data disks.
- Consistent Terraform-managed and environment-aware tags.

## Architecture

The modules have no module-to-module dependency in their source code. A typical
deployment composes them as follows:

1. `modules/vpc` discovers available AZs, creates one public and one private subnet per selected AZ, and routes private egress through a NAT gateway.
2. `modules/eks` consumes the VPC private subnet IDs and creates the EKS control plane, standard managed node group or Auto Mode configuration, add-ons, and conditional IAM resources.
3. `modules/ec2` consumes a subnet and security group IDs and creates one EC2 instance plus optional EBS volumes and attachments.

The VPC module also creates CloudWatch VPC Flow Logs, their log group, and the
IAM role and policy required to publish the logs. Public and private subnets
are tagged for AWS Load Balancer Controller discovery.

## Requirements

- Terraform `>= 1.9.0`
- AWS provider `~> 6.0`
- AWS credentials with permissions for the resources selected by each module
- An AWS region with enough available AZs for `az_count`

The version constraints are declared in [`modules/vpc/version.tf`](modules/vpc/version.tf).
Initialize and validate from the root directory of the configuration that calls
the module:

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
```

## Use From Git

Reference a module subdirectory and pin `ref` to a release tag or commit. The
`../../modules/...` sources in [`example/`](example/) are only for local demos.

```hcl
module "vpc" {
  source = "git::https://github.com/pratik-khot/aws-terraform-modules.git//modules/vpc?ref=v1.0.0"
}
```

The tag above is illustrative; replace it with a tag that exists in the
repository. Use `ref=main` only while testing unreleased changes. Release tags
should follow semantic versioning:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Module Summary

| Module | Creates | Primary use |
| --- | --- | --- |
| [`modules/vpc`](modules/vpc/) | VPC, public/private subnets, NAT, routes, Flow Logs, and optional security group | Foundational AWS networking |
| [`modules/eks`](modules/eks/) | EKS cluster, standard node group or Auto Mode, add-ons, and conditional IAM | Managed Kubernetes |
| [`modules/ec2`](modules/ec2/) | One EC2 instance, root EBS disk, optional data disks, and attachments | Stateful or general-purpose compute |

## VPC Module

### Usage

```hcl
module "vpc" {
  source = "git::https://github.com/pratik-khot/aws-terraform-modules.git//modules/vpc?ref=v1.0.0"

  region                = "us-east-1"
  vpc_cidr              = "10.0.0.0/16"
  az_count              = 3
  subnet_newbits        = 8
  nat_availability_mode = "zonal"
  environment           = "dev"
  project_name          = "platform"
  project_owner         = "platform-team"
  default_sg_required   = false
}
```

Creates one public and one private subnet per selected available AZ. Public
subnets route to an internet gateway; private subnets route to a public NAT
gateway. `nat_availability_mode` accepts `zonal` or `regional`. When enabled,
the optional security group allows TCP ports 22, 80, and 443 from
`0.0.0.0/0`, plus all outbound traffic. Restrict or disable this group for
production workloads.

### Inputs

| Variable | Type | Required | Default | Allowed values | Description | Example |
| --- | --- | --- | --- | --- | --- | --- |
| `vpc_cidr` | `string` | No | `"10.0.0.0/16"` | Valid IPv4 CIDR | VPC address range used to calculate subnet CIDRs. | `"10.20.0.0/16"` |
| `az_count` | `number` | No | `3` | Available AZ count or fewer | Number of available AZs to use. | `3` |
| `subnet_newbits` | `number` | No | `8` | Valid `cidrsubnet` width | Number of bits added when deriving public and private subnets. | `8` |
| `region` | `string` | No | `"us-east-1"` | Any AWS region | AWS region for the VPC resources. | `"eu-west-1"` |
| `nat_availability_mode` | `string` | No | `"zonal"` | `zonal`, `regional` | NAT gateway availability mode. | `"regional"` |
| `environment` | `string` | No | `"dev"` | `dev`, `prod`, `test` are defined tag profiles; other values get no profile | Environment used in tags and the public security group description. | `"prod"` |
| `project_name` | `string` | No | `"Infra"` | Naming-safe project identifier | Project name used in resource names and tags. | `"payments"` |
| `project_owner` | `string` | No | `"Infra Team"` | Team or owner name | Owner recorded in tags. | `"platform-team"` |
| `default_sg_required` | `bool` | No | `true` | `true`, `false` | Whether to create the public access security group. | `false` |
| `log_group_kms_key_arn` | `string` | No | `null` | KMS key ARN or `null` | Optional KMS key for encrypting the Flow Logs log group. | `"arn:aws:kms:us-east-1:123456789012:key/example"` |
| `log_group_retention_in_days` | `number` | No | `365` | CloudWatch-supported retention period | CloudWatch retention for VPC Flow Logs. | `90` |

### Outputs

| Output | Description | Example |
| --- | --- | --- |
| `vpc_id` | ID of the VPC. | `module.vpc.vpc_id` |
| `public_subnet_ids` | IDs of all public subnets. | `module.vpc.public_subnet_ids` |
| `private_subnet_ids` | IDs of all private subnets. | `module.vpc.private_subnet_ids` |
| `public_subnet_map` | Map from availability zone to public subnet ID. | `module.vpc.public_subnet_map["us-east-1a"]` |
| `private_subnet_map` | Map from availability zone to private subnet ID. | `module.vpc.private_subnet_map["us-east-1a"]` |

### Variable Details

#### `vpc_cidr`

Description: VPC address range used to calculate subnet CIDRs. Type: `string`.
Default: `"10.0.0.0/16"`. Example: `vpc_cidr = "10.20.0.0/16"`. Business
impact: determines the private address capacity of the network.

#### `az_count`

Description: Number of available AZs to use. Type: `number`. Default: `3`.
Example: `az_count = 3`. Business impact: controls resilience and the number
of public/private subnet pairs.

#### `subnet_newbits`

Description: Bits added when deriving subnet CIDRs. Type: `number`. Default: `8`.
Example: `subnet_newbits = 8`. Business impact: controls subnet size and
workload address capacity.

#### `region`

Description: AWS deployment region. Type: `string`. Default: `"us-east-1"`.
Example: `region = "eu-west-1"`. Business impact: determines data residency,
latency, and regional service availability.

#### `nat_availability_mode`

Description: NAT gateway availability mode. Type: `string`. Default: `"zonal"`.
Allowed: `zonal`, `regional`. Example: `nat_availability_mode = "regional"`.
Business impact: balances egress resilience, topology, and cost.

#### `environment`

Description: Environment used in tags and descriptions. Type: `string`. Default:
`"dev"`. Example: `environment = "prod"`. Business impact: selects the VPC
backup tag profile for `dev`, `prod`, or `test`.

#### `project_name`

Description: Project naming prefix. Type: `string`. Default: `"Infra"`. Example:
`project_name = "payments"`. Business impact: gives shared resources a stable
ownership and discovery identity.

#### `project_owner`

Description: Project owner tag. Type: `string`. Default: `"Infra Team"`. Example:
`project_owner = "platform-team"`. Business impact: supports accountability
and operational escalation.

#### `default_sg_required`

Description: Creates the public access security group when true. Type: `bool`.
Default: `true`. Example: `default_sg_required = false`. Business impact:
controls whether the module introduces broad internet ingress.

#### `log_group_kms_key_arn`

Description: Optional KMS key for Flow Logs. Type: `string`. Default: `null`.
Example: `log_group_kms_key_arn = "arn:aws:kms:..."`. Business impact: enables
compliance-aligned encryption key control.

#### `log_group_retention_in_days`

Description: CloudWatch Flow Logs retention. Type: `number`. Default: `365`.
Example: `log_group_retention_in_days = 90`. Business impact: sets the balance
between audit history and log storage cost.

The module currently has one explicit validation rule: `nat_availability_mode` must be `zonal` or `regional`.
The module does not validate CIDR arithmetic, AZ capacity, or naming strings;
validate those constraints in the calling configuration.

## EKS Module

### Usage

```hcl
module "eks" {
  source          = "git::https://github.com/pratik-khot/aws-terraform-modules.git//modules/eks?ref=v1.0.0"
  cluster_name    = "platform-eks"
  cluster_version = "1.36"
  region          = "us-east-1"
  subnet_ids      = module.vpc.private_subnet_ids
  auth_mode       = "API_AND_CONFIG_MAP"
  eks_mode        = "standard"
  create_lbc_role = false
}
```

The cluster enables API, audit, authenticator, controller manager, and
scheduler control-plane logs and enables both private and public API endpoints.
Standard mode creates a managed node group with desired size 2, minimum 1, and
maximum 3. Auto Mode enables general-purpose node pools, block storage, and
elastic load balancing and creates the corresponding AWS-managed IAM roles.

### Inputs

| Variable | Type | Required | Default | Allowed values | Description | Example |
| --- | --- | --- | --- | --- | --- | --- |
| `cluster_name` | `string` | Yes | N/A | AWS/EKS naming rules | EKS cluster name and prefix for IAM and node-group resources. | `"platform-eks"` |
| `cluster_version` | `string` | No | `"1.36"` | EKS-supported Kubernetes version | Kubernetes version for the control plane and add-on lookup. | `"1.35"` |
| `subnet_ids` | `list(string)` | Yes | N/A | Existing subnet IDs | Subnets for the EKS control plane and standard nodes/Fargate. | `module.vpc.private_subnet_ids` |
| `region` | `string` | Yes | N/A | Any AWS region | AWS region used by the cluster connection command. | `"us-east-1"` |
| `creator_admin_permissions` | `bool` | No | `true` | `true`, `false` | Grants the cluster creator bootstrap administrator permissions. | `false` |
| `auth_mode` | `string` | No | `"API_AND_CONFIG_MAP"` | `API_AND_CONFIG_MAP`, `API`, `CONFIG_MAP` | EKS authentication mode. | `"API"` |
| `eks_mode` | `string` | No | `"standard"` | `standard`, `auto` | Selects a managed node group or EKS Auto Mode. | `"auto"` |
| `enable_fargate` | `bool` | No | `false` | `true`, `false` | Creates a Fargate profile for the selected namespace. | `true` |
| `fargate_namespace` | `string` | No | `"default"` | Kubernetes namespace | Namespace selected by the optional Fargate profile. | `"workloads"` |
| `addons` | `map(any)` | No | `{}` | Add-on names; optional `version` per entry | Add-ons to merge with mode-specific defaults. | `{ coredns = { version = "v1.12.0-eksbuild.1" } }` |
| `create_lbc_role` | `bool` | No | `false` | `true`, `false` | Creates the AWS Load Balancer Controller policy, role, and pod identity association in standard mode. | `true` |

Standard mode defaults to `coredns`, `kube-proxy`, `vpc-cni`,
`eks-pod-identity-agent`, and `aws-ebs-csi-driver`. Auto Mode defaults to
`eks-pod-identity-agent`. User entries in `addons` override matching defaults;
an omitted add-on version is resolved to the most recent version compatible
with the cluster Kubernetes version.

### Outputs

| Output | Description | Example |
| --- | --- | --- |
| `cluster_connection` | AWS CLI command that updates the local kubeconfig. | `terraform output -raw cluster_connection` |

### Variable Details

#### `cluster_name`

Description: EKS cluster name and IAM/resource prefix. Type: `string`. Required.
Example: `cluster_name = "platform-eks"`. Business impact: identifies the
cluster and its workload control plane resources.

#### `cluster_version`

Description: Kubernetes control-plane version. Type: `string`. Default: `"1.36"`.
Example: `cluster_version = "1.35"`. Business impact: determines supported
features, add-on compatibility, and upgrade planning.

#### `subnet_ids`

Description: Subnets for EKS resources. Type: `list(string)`. Required. Example:
`subnet_ids = module.vpc.private_subnet_ids`. Business impact: determines
cluster placement and workload network reachability.

#### `region`

Description: AWS region for the cluster connection command. Type: `string`.
Required. Example: `region = "us-east-1"`. Business impact: keeps CLI access
and resource placement aligned.

#### `creator_admin_permissions`

Description: Grants bootstrap admin access to the creator. Type: `bool`. Default:
`true`. Example: `creator_admin_permissions = false`. Business impact: controls
initial administrative access and should be reviewed for separation of duties.

#### `auth_mode`

Description: EKS authentication mode. Type: `string`. Default:
`"API_AND_CONFIG_MAP"`. Allowed: `API_AND_CONFIG_MAP`, `API`, `CONFIG_MAP`.
Example: `auth_mode = "API"`. Business impact: controls how Kubernetes access
is governed.

#### `eks_mode`

Description: EKS compute operating mode. Type: `string`. Default: `"standard"`.
Allowed: `standard`, `auto`. Example: `eks_mode = "auto"`. Business impact:
chooses between explicit managed nodes and AWS-managed Auto Mode operations.

#### `enable_fargate`

Description: Enables a namespace-scoped Fargate profile. Type: `bool`. Default:
`false`. Example: `enable_fargate = true`. Business impact: provides serverless
pod capacity with different cost and workload constraints.

#### `fargate_namespace`

Description: Namespace selected by the Fargate profile. Type: `string`. Default:
`"default"`. Example: `fargate_namespace = "workloads"`. Business impact:
controls which pods are scheduled onto Fargate.

#### `addons`

Description: Add-ons merged with mode-specific defaults. Type: `map(any)`.
Default: `{}`. Example: `addons = { coredns = { version = "v1.12.0-eksbuild.1" } }`.
Business impact: controls core cluster capabilities and their upgrade versions.

#### `create_lbc_role`

Description: Creates AWS Load Balancer Controller IAM resources in standard mode.
Type: `bool`. Default: `false`. Example: `create_lbc_role = true`. Business
impact: enables controller access to provision and manage AWS load balancers.

The explicit validation rules
are `auth_mode` in `API_AND_CONFIG_MAP`, `API`, or `CONFIG_MAP`, and `eks_mode`
in `standard` or `auto`. `create_lbc_role` is ignored for Auto Mode because
Auto Mode manages load balancing through its own configuration.

## EC2 Module

### Usage

```hcl
module "ec2" {
  source               = "git::https://github.com/pratik-khot/aws-terraform-modules.git//modules/ec2?ref=v1.0.0"
  ami_id               = "ami-0123456789abcdef0"
  instance_type        = "t3.micro"
  subnet_id            = module.vpc.private_subnet_ids[0]
  sg_ids               = [aws_security_group.app.id]
  app_name             = "demo-app"
  env                  = "dev"
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

Creates exactly one `aws_instance`. The AMI, subnet, security groups, and
optional IAM instance profile are supplied by the caller. Each entry in
`data_volume_specs` creates one EBS volume and one attachment, keyed by the
logical map key. `ami_id` and `subnet_id` default to `null` in the module, but a
usable EC2 deployment still requires values accepted by the AWS provider.

### Inputs

| Variable | Type | Required | Default | Allowed values | Description | Example |
| --- | --- | --- | --- | --- | --- | --- |
| `ami_id` | `string` | No* | `null` | Existing AMI ID | AMI used by the instance. | `"ami-0123456789abcdef0"` |
| `instance_type` | `string` | No | `"t3.micro"` | AWS-supported instance type | EC2 instance type. | `"t3.small"` |
| `private_ip` | `string` | No | `null` | Valid private IPv4 address | Optional primary private IP. | `"10.20.1.20"` |
| `instance_no` | `number` | No | `1` | Numeric identifier | Number included in the instance `Name` tag. | `2` |
| `availability_zone` | `string` | No | `null` | AZ in the selected region | Optional placement AZ; must align with the subnet. | `"us-east-1a"` |
| `subnet_id` | `string` | No* | `null` | Existing subnet ID | Subnet where the instance launches. | `module.vpc.private_subnet_ids[0]` |
| `sg_ids` | `list(string)` | No | `[]` | Existing security group IDs | Security groups attached to the instance. | `[aws_security_group.app.id]` |
| `enable_public_ip` | `bool` | No | `false` | `true`, `false` | Whether to associate a public IPv4 address. | `false` |
| `key_name` | `string` | No | `null` | Existing EC2 key pair name | Optional SSH key pair. | `"platform-admin"` |
| `enable_monitoring` | `bool` | No | `true` | `true`, `false` | Enables detailed CloudWatch monitoring. | `true` |
| `ebs_optimized` | `bool` | No | `false` | `true`, `false` | Enables EBS optimization where supported. | `true` |
| `user_data` | `string` | No | `null` | Bootstrap script or `null` | Script passed to instance initialization. | `file("bootstrap.sh")` |
| `tags` | `map(string)` | No | `{}` | Key/value pairs | Additional instance tags merged last and able to override defaults. | `{ costcenter = "12345" }` |
| `app_name` | `string` | No | `"demo-app"` | Naming-safe application name | Application tag and resource-name prefix. | `"orders"` |
| `env` | `string` | No | `"dev"` | Environment identifier | Environment tag and resource-name component. | `"prod"` |
| `disable_api_termination` | `bool` | No | `false` | `true`, `false` | Prevents API termination when enabled. | `true` |
| `disable_api_stop` | `bool` | No | `false` | `true`, `false` | Prevents API stop when enabled. | `false` |
| `root_volume_specs` | `object` | No | `{ size = 20, type = "gp3", delete_on_termination = true, encrypted = true }` | See schema below | Root EBS volume settings. | `{ size = 40, type = "gp3", delete_on_termination = true, encrypted = true }` |
| `data_volume_specs` | `map(object)` | No | `{}` | See schema below | Optional EBS data volumes keyed by logical name. | `{ data = { size = 100, device_name = "/dev/sdf" } }` |
| `iam_instance_profile` | `string` | No | `null` | Existing instance profile name | IAM instance profile attached to the instance. | `aws_iam_instance_profile.app.name` |

`*` These inputs have no Terraform `validation` block, but AWS requires a valid
AMI and subnet for a successful instance launch.

`root_volume_specs` requires `size` and `delete_on_termination`; `type` is
optional and defaults to `"gp3"`, `encrypted` is optional and defaults to
`true`, and `kms_key_id` is optional. Each `data_volume_specs` entry requires
`size` and `device_name`; it also supports optional `instance_key`, `type`
(`"gp3"`), `delete_on_termination` (`true`), `encrypted` (`true`),
`kms_key_id`, `iops`, and `throughput`.

### Outputs

| Output | Description | Example |
| --- | --- | --- |
| `instance_id` | ID of the EC2 instance. | `module.ec2.instance_id` |
| `instance_private_ip` | Primary private IP of the instance. | `module.ec2.instance_private_ip` |
| `instance_public_ip` | Public IP, or `null` when public IP association is disabled. | `module.ec2.instance_public_ip` |
| `attached_ebs_volume_ids` | Map from logical data-volume name to EBS volume ID. | `module.ec2.attached_ebs_volume_ids["app_data"]` |

### Variable Details

#### `ami_id`

Description: AMI used by the instance. Type: `string`. Default: `null`. Example:
`ami_id = "ami-0123456789abcdef0"`. Business impact: determines the operating
system and software baseline.

#### `instance_type`

Description: EC2 instance type. Type: `string`. Default: `"t3.micro"`. Example:
`instance_type = "t3.small"`. Business impact: sets compute capacity and cost.

#### `private_ip`

Description: Optional primary private IP. Type: `string`. Default: `null`.
Example: `private_ip = "10.20.1.20"`. Business impact: supports stable internal
addressing where required.

#### `instance_no`

Description: Number used in the `Name` tag. Type: `number`. Default: `1`. Example:
`instance_no = 2`. Business impact: distinguishes instances in operations.

#### `availability_zone`

Description: Optional placement AZ. Type: `string`. Default: `null`. Example:
`availability_zone = "us-east-1a"`. Business impact: affects locality and must
match the selected subnet.

#### `subnet_id`

Description: Launch subnet. Type: `string`. Default: `null`. Example:
`subnet_id = module.vpc.private_subnet_ids[0]`. Business impact: determines
network isolation and internet exposure.

#### `sg_ids`

Description: Attached security groups. Type: `list(string)`. Default: `[]`.
Example: `sg_ids = [aws_security_group.app.id]`. Business impact: controls
instance network access.

#### `enable_public_ip`

Description: Associates a public IPv4 address. Type: `bool`. Default: `false`.
Example: `enable_public_ip = false`. Business impact: controls direct internet
reachability and exposure.

#### `key_name`

Description: Optional EC2 key pair. Type: `string`. Default: `null`. Example:
`key_name = "platform-admin"`. Business impact: provides legacy SSH access.

#### `enable_monitoring`

Description: Enables detailed monitoring. Type: `bool`. Default: `true`. Example:
`enable_monitoring = true`. Business impact: improves telemetry with additional
CloudWatch cost.

#### `ebs_optimized`

Description: Enables EBS optimization. Type: `bool`. Default: `false`. Example:
`ebs_optimized = true`. Business impact: improves storage I/O where supported.

#### `user_data`

Description: Bootstrap script. Type: `string`. Default: `null`. Example:
`user_data = file("bootstrap.sh")`. Business impact: standardizes instance
configuration at launch.

#### `tags`

Description: Additional instance tags. Type: `map(string)`. Default: `{}`.
Example: `tags = { costcenter = "12345" }`. Business impact: supports cost
allocation and service ownership; caller tags override defaults.

#### `app_name`

Description: Application naming prefix. Type: `string`. Default: `"demo-app"`.
Example: `app_name = "orders"`. Business impact: groups compute resources by
service.

#### `env`

Description: Environment name. Type: `string`. Default: `"dev"`. Example:
`env = "prod"`. Business impact: separates operational and cost boundaries.

#### `disable_api_termination`

Description: Prevents API termination when enabled. Type: `bool`. Default: `false`.
Example: `disable_api_termination = true`. Business impact: protects critical
instances from accidental deletion.

#### `disable_api_stop`

Description: Prevents API stop when enabled. Type: `bool`. Default: `false`.
Example: `disable_api_stop = true`. Business impact: protects workloads that
must remain continuously available.

#### `root_volume_specs`

Description: Root EBS settings. Type: `object`. Default: size `20`, type `"gp3"`,
delete on termination `true`, encrypted `true`. Example:
`root_volume_specs = { size = 40, type = "gp3", delete_on_termination = true, encrypted = true }`.
Business impact: sets boot-disk capacity, persistence, performance, and
encryption.

#### `data_volume_specs`

Description: Optional logical-name-to-EBS-volume map. Type: `map(object)`.
Default: `{}`. Example: `data_volume_specs = { data = { size = 100, device_name = "/dev/sdf" } }`.
Business impact: provisions durable application storage separately from the
root disk.

#### `iam_instance_profile`

Description: IAM instance profile name. Type: `string`. Default: `null`. Example:
`iam_instance_profile = aws_iam_instance_profile.app.name`. Business impact:
grants the instance its AWS permissions without embedding credentials.

The module has no explicit
Terraform validation blocks, so validate AMI, subnet, AZ, device names, EBS
capabilities, and naming constraints in the calling configuration.

## Naming Convention

The modules use caller-provided project, application, environment, and cluster
values rather than a single global naming function:

| Resource | Format |
| --- | --- |
| VPC | `<project_name>-vpc` |
| Public subnet | `<project_name>-vpc-pub-sub-<az-short-name>` |
| Private subnet | `<project_name>-vpc-pvt-sub-<az-short-name>` |
| NAT gateway | `<project_name>-vpc-nat-gw-<mode-initial>` |
| EC2 instance | `<app_name>-<env>-<instance_no>` |
| EC2 data volume | `<app_name>-<env>-<logical-volume-name>` |
| EKS cluster IAM role | `<cluster_name>-eks-cluster-role` |
| EKS node group | `<cluster_name>-node-group` |

Use short, stable, AWS-compatible values for `project_name`, `app_name`,
`env`, and `cluster_name`. The VPC subnet AZ suffix is derived from the AZ
string, for example `us-east-1a` becomes `use1a`.

## Tagging Strategy

VPC resources receive `managed_by = "terraform"`, `project_name`,
`project_owner`, and an environment profile. The `dev`, `prod`, and `test`
profiles set `environment` and `Backup`; `prod` sets `Backup = "true"`, while
`dev` and `test` set it to `"false"`. EKS resources receive
`managed_by = "terraform"`, `cluster_name`, and `eks_mode`. EC2 resources
receive `ManagedBy = "Terraform"`, `Environment`, `Application`, the generated
`Name`, and caller-supplied `tags`.

Example:

```hcl
tags = {
  costcenter = "12345"
  owner      = "platform-team"
}
```

Do not put credentials, secrets, or sensitive operational data in tags.

## Environment Examples

The VPC module recognizes these environment profiles:

### Production

```hcl
environment = "prod"
```

Sets `environment = "prod"` and `Backup = "true"` on VPC resources.

### Non-Production

```hcl
environment = "dev"
```

Sets `environment = "dev"` and `Backup = "false"`. Use `test` for a separate
test profile:

```hcl
environment = "test"
```

### Sandbox

There is no dedicated `sandbox` tag profile in the source. To avoid silently
omitting environment tags, use `dev` or add a `sandbox` profile in
`modules/vpc/locals.tf` before using it:

```hcl
environment = "dev"
```

### Shared Services

There is no dedicated `shared` tag profile in the source. Use a clear project
name and owner, and use `dev`, `prod`, or `test` according to the backup policy:

```hcl
project_name  = "shared-services"
project_owner = "platform-team"
environment   = "prod"
```

## Best Practices

- Pin module sources to immutable release tags or commit SHAs and review changes before upgrading.
- Store Terraform state in a remote backend with locking and encryption; keep state out of source control.
- Use least-privilege AWS roles for Terraform and workload IAM. Review the AWS-managed policies created by the EKS module.
- Disable `default_sg_required` or replace the broad default rules with workload-specific security groups.
- Keep EKS API access and EC2 public IP assignment intentional; prefer private subnets for workloads.
- Encrypt root, data, and Flow Logs volumes with approved KMS keys where required.
- Run `terraform fmt`, `terraform validate`, `terraform plan`, and policy/security checks in CI before apply.
- Separate state and credentials by environment and protect production applies with review and approval gates.

## Troubleshooting

| Symptom | Checks |
| --- | --- |
| Missing required variables | EKS requires `cluster_name`, `subnet_ids`, and `region`. Confirm the caller passes valid values. |
| Invalid mode or authentication value | Use only the validated `nat_availability_mode`, `auth_mode`, and `eks_mode` values listed above. |
| Provider authentication failure | Check the selected AWS profile/role, region, credentials, and IAM permissions. |
| Too few availability zones | Lower `az_count` or choose a region with enough available AZs. |
| CIDR or subnet creation failure | Confirm `vpc_cidr` and `subnet_newbits` produce non-overlapping valid CIDRs. |
| EKS add-on version failure | Confirm the add-on is supported for `cluster_version`; omit `version` to use the latest compatible version. |
| EKS or Fargate placement failure | Confirm `subnet_ids` are in the target region and have the required routing and IAM permissions. |
| EC2 launch failure | Confirm the AMI, subnet, AZ, security groups, device names, and instance type are mutually compatible. |
| Naming or tagging mismatch | Use stable values for naming inputs and remember that VPC environment tags are only defined for `dev`, `prod`, and `test`. |

## Examples

Working root configurations are available under [`example/`](example/):

- [`example/vpc/`](example/vpc/) creates the VPC module and exports its subnet IDs.
- [`example/eks/`](example/eks/) creates EKS and reads VPC private subnet IDs from Terraform remote state.

The example environments demonstrate remote state usage: VPC uses a Terraform
Cloud backend, while EKS uses an S3 backend with the lockfile option. Review and
replace the backend organization, workspace, bucket, and key before applying.

## Changelog Notes

- VPC module: multi-AZ network container, public/private routing, NAT gateway, optional public security group, and Flow Logs with optional KMS encryption.
- EKS module: standard managed node group, Auto Mode support, mode-aware managed add-ons, CNI/EBS CSI pod identity, optional Fargate, and optional Load Balancer Controller IAM resources.
- EC2 module: one configurable EC2 instance, root volume controls, optional data-volume creation and attachment, and instance/volume outputs.
