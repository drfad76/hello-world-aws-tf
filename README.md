# SRE coding challenge repository

This repository contain everything that is required to provision the following infrastructure in AWS:
* Simple WEB server, hosting a "Hello World!" web page
* All rules and security permissions to facilitate dynamic hosting
* CloudWatch alarm to monitor CPU utilisation

## Infrastructure rollout prerequisites

Infrastructure code is designed to run on Windows, Linux and Mac as all components available for any platforms.

While this deployment repository contains everything that is required to deploy and monitor infrastructure automatically from the current repository location. There are some prerequisites you require to install for this code to work.

* [Hashicorp](https://www.terraform.io/) terrafrom go binary (tested with Terraform v0.15.0). Please download from [here](https://releases.hashicorp.com/terraform/)
* Bash command line shell
* JQ utility available [here](https://stedolan.github.io/jq/download/)

### AWS account setup

To be able to rollout the infrastructure, one need to have AWS account provisioned AWS CLI installed and configured.

Here is the set of steps required to be performed.

1. Sign-in for AWS account
2. Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
3. [Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) AWS CLI
4. Setup AWS CLI [credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

### AWS account first time setup test

Once you provision AWS account, setup prerequisites and configure AWS CLI first time. Run the following commands to setup default VPC and test your AWS connectivity.

```
aws ec2 create-default-vpc
aws sts get-caller-identity

# if everything is setup correctly you will get similar response

{
    "UserId": "380165XXXXX",
    "Account": "380165XXXXXX",
    "Arn": "arn:aws:iam::380165XXXXX:root"
}
```

### Infrastructure provisioning

Once AWS account provisioned, AWS CLI configured and prerequisites are installed, the infrastructure is ready for provisioning.

To provision the infrastructure run the following set of commands in the root folder of this repository:
```
# initialise terraform modules
terraform init

# inspect what changes are scheduled to be implemented
terraform plan

# build the infrastructure
terrafrom apply
```
### Validating provisioned infrastructure
It will take some time for the terraform to provision AWS infrastructure and install a web server. Once installation is complete and ready to use, at the end of provisioning, terrafrom will show the output information, similar to this:
```
Outputs:

instance_dns = [
  [
    "ec2-3-25-204-133.ap-southeast-2.compute.amazonaws.com",
  ],
]
instance_ips = [
  [
    "3.25.204.133",
  ],
]
```
You can validate infrastructure installation success by browsing to the server DNS name.
e.g http://ec2-3-25-204-133.ap-southeast-2.compute.amazonaws.com.

*Please note that for the purpose of this example server is only configured to use **http** and and not **https**. Please also note that DNS is dynamic and changes every time you destroy and provision new infrastructure.*

### Web server local monitoring script

You can also monitor the status of your WEB server from your computer locally via supplied monitoring script. Script is designed to constantly run, with configurable intervals, preset to 2 seconds. There is no need to customise this script it will find provisioned WEB server automatically and start monitoring on the console. Script is designed to be executed in the same working directory of this repository. To use it, just run:
```
./monitor.sh

# You will be able to the similar output. 

Wed 20 08:10:44 ~/Git/temp/hello-world-aws-tf (master)
-(0)nonR> ./monitor.sh
Monitoring web server: ec2-3-25-204-133.ap-southeast-2.compute.amazonaws.com
Webserver is running.
Webserver is running.
Webserver is running.
Webserver is running.
Webserver is running.
Webserver is running.
Webserver is running.
Webserver is running.
Webserver is running.
Webserver is running.
```
#### Side note 
If you run monitoring script before AMI is fully provisioned you may reseive an error "Webserver is not available". Please give some time to AWS to provision a new server, before running the monitoring script.

