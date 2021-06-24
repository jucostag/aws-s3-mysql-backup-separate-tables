# MySQL backups on AWS S3
Dump your tables separately and automatically upload to your S3 bucket.

### Requirements

- [S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/creating-bucket.html)
- Access key and secret from [IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)
- Neutral directory for temporary files

### Getting started

- Fill up the variables:

    TMP_DIR=

    AWS_S3_ACCESS_KEY_ID=
    AWS_S3_ACCESS_SECRET_KEY=
    AWS_S3_DEFAULT_REGION=
    AWS_S3_BUCKET=

    DB_TABLES_PREFIX=

- Copy the .sh script to your ~/bin directory, so you can use it on terminal. Don't forget to include the ~/bin dir on your .bashrc, for this to work.

```
export PATH=$PATH:~/bin
```

- Execute the script, passing the arguments

$ s3bkp your-s3-directory your-mysql-user your-mysql-pass mysql-IP your-mysql-db-name