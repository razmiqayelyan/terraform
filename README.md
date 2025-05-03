✅ README.md

# 🚀 Terraform Auto Scaling Web App with Rolling Updates

This Terraform project provisions a **scalable, load-balanced web application** on AWS using:

- Auto Scaling Group (ASG)
- Launch Template with dynamic `user_data.sh`
- Classic Load Balancer (CLB)
- Default VPC & Subnets (across 2 AZs)
- Rolling instance updates on user data changes

---

## 📁 Project Structure

```bash
.
├── main.tf               # Core resources: ASG, ELB, Launch Template
├── data.tf               # Data sources: AMI, subnets, AZs
├── variables.tf          # Input variables (optional)
├── outputs.tf            # Outputs: ELB DNS, etc.
├── security.tf           # Security group rules
├── user_data.sh          # Script to install and start Apache
├── README.md             # You're here



⸻

💡 Features

✅ Launch Template with filebase64(user_data.sh)
✅ Rolling EC2 instance replacement when user_data.sh changes
✅ Uses filesha256() to track changes and force template refresh
✅ Instance refresh triggered by ASG tag diff
✅ Classic Load Balancer spans 2 AZs
✅ Default VPC and subnets — no networking config required
✅ Apache web server deployed automatically

⸻

🧰 Requirements
	•	Terraform 1.3+
	•	AWS account
	•	AWS CLI configured with:
	•	AWS_ACCESS_KEY_ID
	•	AWS_SECRET_ACCESS_KEY

⸻

🚀 Usage

1. Clone the repo

git clone https://github.com/razmiqayelyan/terraform
cd terraform-asg-webapp

2. Initialize Terraform

terraform init

3. Apply the configuration

terraform apply

Confirm with yes.

⸻

🌍 Access the Web App

Once applied, Terraform will output the ELB DNS name:

Outputs:

elb_dns_name = my-classic-lb-1234567890.us-east-1.elb.amazonaws.com

Open that URL in your browser — you’ll see a basic Apache page with hostname.

⸻

🔁 Updating user_data.sh

To update the EC2 script:
	1.	Edit user_data.sh
	2.	Save changes
	3.	Run:

terraform apply

Terraform will:
	•	Detect changes via filesha256("user_data.sh")
	•	Update the launch template
	•	Trigger a rolling refresh of EC2 instances
	•	New instances will launch with new user data
	•	Old instances will be terminated automatically 🎯

⸻

🧼 Clean Up

To destroy everything:

terraform destroy



⸻

📄 License

MIT License — use freely, contribute back!
