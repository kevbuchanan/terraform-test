# Project Infrastructure

Exploring Elixir web app infrastructure setup with Terraform and AWS

## Setup

- Install [Terraform](https://www.terraform.io/intro/getting-started/install.html)
  * On a mac: `brew install terraform`
- Put your [AWS IAM](https://aws.amazon.com/iam/) credentials at `~/.aws/credentials` using the `terraform-test` profile.

```
[terraform-test]
aws_access_key_id = <access-key>
aws_secret_access_key = <secret>
```

## Usage

`terraform workspace select <staging | production>`

`terraform plan`

`terraform apply`

## Additional Resources and Ideas

- [Terraform AWS](https://www.terraform.io/docs/providers/aws/)
- [Terraform Rolling Deploys](https://github.com/robmorgan/terraform-rolling-deploys)
- [Clustering](https://github.com/bitwalker/libcluster)
- [Clustering AWS](https://github.com/kyleaa/libcluster_ec2)
