#!/bin/bash

## Destroy a Jenkins server
cd ./jenkins-vault_server
terraform destroy -auto-approve

# Defining a local name
LOCAL_NAME="auto-discovery-mono-app"

# Define the necessary variables
DYNAMODB_TABLE_NAME="${LOCAL_NAME}-dynamodb"
S3_BUCKET_NAME="${LOCAL_NAME}-s3"
AWS_REGION="eu-west-1"
AWS_PROFILE="petproject"  

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        echo "$1 succeeded."
    else
        echo "$1 failed." >&2
        exit 1
    fi
}

# Deleting DynamoDB table
echo "Deleting DynamoDB table: $DYNAMODB_TABLE_NAME ..."
aws dynamodb delete-table --table-name "$DYNAMODB_TABLE_NAME" --region "$AWS_REGION" --profile "$AWS_PROFILE"
check_success "DynamoDB table deletion"

# Deleting S3 bucket (force delete to remove all objects)
echo "Deleting S3 bucket: $S3_BUCKET_NAME ..."
aws s3 rb "s3://$S3_BUCKET_NAME" --force --region "$AWS_REGION" --profile "$AWS_PROFILE"
check_success "S3 bucket deletion"

# Final success message
echo "All AWS resources deleted successfully."

