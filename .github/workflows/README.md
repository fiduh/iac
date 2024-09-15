#### GitHub Actions

[OIDC-1](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/)
[OIDC-2](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

Create an Identity provider in AWS *https://token.actions.githubusercontent.com* --> Audience *sts.amazonaws.com* --> Assign role (Web identity) --> Configure aws credentials in Github Actions using *aws-actions/configure-aws-credentials@v2*