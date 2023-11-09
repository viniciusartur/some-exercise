# iofinnet-terraform

This project terraforms a Cloudfront distribution per each environment (dev, staging and production), supporting distinct paths (/auth, /info and /customers), each of them linked to a separate S3 bucket.

## Design decisions

 - The distinct paths are defined in a single source of truth, which is modules/webapp-infra/variables.tf.
 - It's relying on Terraform Modules and Dynamic blocks to ensure the DRY principle.

## Key assumptions

 - There's no need of configuring encryption or ACL for the S3 bucket, as they come configured like this by default
 - Terraform backend is the default `local` 
 - Access to Cloudfront is restricted by some specific countries

## How to run?

Just run:
```
cd environments/dev
terraform plan
terraform apply
```

## How to test?

1. Create some data:
```
seq 3 | xargs -I {} bash -c "echo bucket{} | tee /tmp/bucket{}.txt"
```

2. Upload it on the S3 buckets for the desided environment:
```
BUCKET=xtesttest2x-bucket3-dev
aws s3 cp /tmp/bucket1.txt "s3://${BUCKET}/auth/"
aws s3 cp /tmp/bucket2.txt "s3://${BUCKET}/info/"
aws s3 cp /tmp/bucket3.txt "s3://${BUCKET}/customers/"
```

3. Run the test:
```
CLOUDFRONT_URL=https://d3jz0esynvfnaz.cloudfront.net
curl "${CLOUDFRONT_URL}/customers/bucket1.txt"
curl "${CLOUDFRONT_URL}/customers/bucket2.txt"
curl "${CLOUDFRONT_URL}/customers/bucket3.txt"
```
