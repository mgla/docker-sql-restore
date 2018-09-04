# s3-batch-sql-restore
Docker based sql restore for execution in AWS Batch environments

Mandatory variables:

    MYSQL_HOST MYSQL_PWD MYSQL_USER DB_DATABASE S3_BUCKET S3_PATH

Downloads all files in `S3_PATH`, gunzips them and pipes them into MySQL.

Should work with arbitrary file sizes, as streaming from S3 is used.
