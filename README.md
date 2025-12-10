README — Private ALB + ASG + S3 Endpoint Setup

please go under dev folder and configure your bucket/key/dynamo db table and in dev.tfvars your enviornmetn and region in variables then use init / apply with tfvar file and destroy once tested. its end to end working code for the nginx.

Activities achieved by the terraform code with modular approch

Create VPC — 10.50.0.0/16 VPC with DNS hostnames and DNS resolution enabled.

Create Public Subnets — Three public subnets for ALB and NAT gateway placement.

Create Private Subnets — Three private subnets for ASG instances, no public IPs.

Create Internet Gateway — Attach IGW and route public subnets to internet.

Create Route Tables — Public routes → IGW, Private routes → NAT gateway.

Create NAT Gateways — One per public subnet to allow outbound internet from private.

Create S3 Gateway Endpoint — Configure S3 endpoint and associate with private route tables.

Create Security Group (ALB) — Allow inbound 80 from internet, outbound all.

Create Security Group (EC2) — Allow inbound 80 from ALB SG, SSH only from bastion SG.

Create Target Group — HTTP:80, health check path /, for ALB target registration.

Create Application Load Balancer — Internet-facing ALB in public subnets, attach ALB SG.

Create Launch Template (v1) — AMI, instance type, SG-EC2, no public IP, user-data installs nginx.

Create Auto Scaling Group — Use LT, private subnets, attach to Target Group, desired capacity set.

Verify ALB DNS — Open ALB DNS; confirm “staging - nginx instanceID” served by nginx.

Optional Bastion — Public bastion SG: SSH from my IP. Private SG: SSH from bastion only.

Validations Performed

ALB → TG → EC2 flow validated via ALB DNS returning nginx content.

TG health checks validated; fixed port/security/path mismatches during boot.

S3 endpoint validated: private EC2 lists and uploads buckets without internet.

IAM role confirmed on new instances via EC2 instance details and successful aws s3 commands.

Mistakes / Learnings

Cannot edit LT version — must create new Launch Template version to add IAM role.

TG unhealthy while ASG shows InService — typically caused by nginx not started, SG or health-path mismatch.

Default SG cannot be referenced — use specific SGs; default SG inbound only references itself.

SSM error due to user IAM — SSM needs IAM user policy or use EC2-ICE / bastion instead.

S3 endpoint ≠ permissions — VPC endpoint solves routing; IAM role still required for authorization.

Quick Recovery Tips

If TG unhealthy: check nginx, SG rules, health check path, and instance routes.

If S3 commands fail: ensure EC2 has IAM role and S3 endpoint associated with private route tables.

For access: prefer EC2 Instance Connect Endpoint or bastion; avoid attaching public IPs to private instances.

Final Note

Keep this README with Terraform modules and exact resource names for reproducible automation later.

