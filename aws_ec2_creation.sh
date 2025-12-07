#!/bin/bash
# AWS EC2 Instance Creation Script
# Description: Creates an EC2 instance with specified parameters
##author: Khushi
#date: 2024-06-15
#version: 1.0
#purpose: Automate EC2 instance creation if in command line argument recieves create then create if command line argument includes delete then delete the ec2 instance
#############################
# Define default variables
#variables
AMI_ID=""  # Replace with a valid AMI ID
INSTANCE_TYPE="t3.micro"
KEY_NAME=""           # Replace with your key pair name
SECURITY_GROUP="" # Replace with your security group name
SECURITY_GROUP_ID="" # Replace with your security group ID
REGION=""               # Replace with your desired region 
TAG_NAME="MyEC2Instanceviacli"

if [[ "$1" == "create" ]]; then
    # Create EC2 instance
    echo "Creating EC2 instance..."
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type $INSTANCE_TYPE \
        --key-name $KEY_NAME \
        --security-groups $SECURITY_GROUP \
        --security-group-ids $SECURITY_GROUP_ID \
        --region $REGION \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$TAG_NAME}]" \
        --query 'Instances[0].InstanceId' \
        --output text)
        #
    echo "EC2 Instance created with Instance ID: $INSTANCE_ID"
    # Wait for the instance to be in running state
    echo "Waiting for instance to enter 'running' state..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION
    echo "Instance is now running."
    # Retrieve and display the public DNS of the instance
    PUBLIC_DNS=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --region $REGION \
        --query 'Reservations[0].Instances[0].PublicDnsName' \
        --output text)
    echo "Public DNS of the instance: $PUBLIC_DNS"# End of script
fi
##
## Delete EC2 instance if "delete" argument is provided
if [[ " $@ " =~ " delete " ]]; then
    if [ -z "$INSTANCE_ID" ]; then
        read -p "Enter the Instance ID to terminate: " INSTANCE_ID
    fi
    echo "Terminating EC2 instance with Instance ID: $INSTANCE_ID"
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION
    echo "Waiting for instance to terminate..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID --region $REGION
    echo "Instance terminated."
fi
# End of script