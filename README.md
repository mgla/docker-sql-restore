# s3-batch-sql-restore
Docker based sql restore for execution in AWS Batch environments

Mandatory variables:

    MYSQL_HOST MYSQL_PWD MYSQL_USER DB_DATABASE S3_BUCKET S3_PATH

Downloads all files in `S3_PATH`, gunzips them and pipes them into MySQL.

Should work with arbitrary file sizes, as streaming from S3 is used.

# How to set up a the AWS CodePipeline pipeline

1. Create a personal access token with GitHub, see https://github.com/settings/tokens and save it for later
   * Needs repo permissions
1. Create a secret with the AWS Secrets Manager containing the keys `secret`and `oauth`. `secret` can be anything - AWS CodePipeline will create the WebHook for you.
   * Note the name of the secret for later use
1. Create a stack with the pipeline.yaml template with the following parameters
   * GitBranch: The git branch which will trigger the pipeline. Example: master
   * GitHubUser: The owner of the repository, i.e. a user name or a organization name
   * GitSourceRepo: The name of the repository without the owner, e.g. s3-batch-sql-restore not mgla/s3-batch-sql-restore
   * PipelineName: The name of the pipeline to be created, will be used as a prefix for all named resources
   * SecretName: The name of the secret you created earlier

## Costs
* The AWS secrets manager will generate some money after 30 days, see https://aws.amazon.com/de/secrets-manager/pricing/
* The stored S3 artifacts will generate some costs, depending on usage.
* The created CodePipeline will generate some costs after 30 days, see https://aws.amazon.com/de/codepipeline/pricing/
* The CodeBuild project will generate some costts, depending on usage, see https://aws.amazon.com/de/codebuild/pricing/
* The generated Docker images will be stored in an ECR repositories, where additional costs may be generated for storage
