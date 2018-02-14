## example-contextual-bandit 

Deployment process:

Run `terraform init`

To deploy there are 2 files to manage but in most cases do not need to be changed:

    preprod.tfvars
    prod.tfvars

Deploy with:

`./deploy.sh environment` (only preprod or prod are needed).


To destroy an environment:

`./destroy.sh environment` (only preprod or prod are needed).
