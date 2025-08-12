#!/bin/bash

# === Configurable variables ===
REGION="us-east-1"
AMI_ID="ami-020cba7c55df1f615"     # Ubuntu 22.04 LTS for us-east-1 (update for your region)
INSTANCE_TYPE="t2.large"
KEY_NAME="psql_keypair"
SECURITY_GROUP_NAME="psql_security_group"
INSTANCE_NAME="pql_management"

# === Step 1: Create a key pair if it doesn't exist ===
echo "🔍 Checking key pair..."
aws ec2 describe-key-pairs --key-names "$KEY_NAME" --region "$REGION" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "🔑 Creating new key pair: $KEY_NAME"
  aws ec2 create-key-pair --key-name "$KEY_NAME" --query 'KeyMaterial' --output text --region "$REGION" > "${KEY_NAME}.pem"
  chmod 400 "${KEY_NAME}.pem"
else
  echo "✅ Key pair already exists. Deleting keys"
  aws ec2 delete-key-pair --key-name "$KEY_NAME" --region "$REGION"
  echo "⏳ Waiting for 10 seconds..."
  sleep 10
  echo "🔑 Re-Creating new key pair: $KEY_NAME"
  aws ec2 create-key-pair --key-name "$KEY_NAME" --query 'KeyMaterial' --output text --region "$REGION" > "${KEY_NAME}.pem"
  chmod 400 "${KEY_NAME}.pem"
fi

# === Step 2: Create a security group if it doesn't exist ===
echo "🔍 Checking security group..."
SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values="$SECURITY_GROUP_NAME" \
  --query "SecurityGroups[0].GroupId" --output text --region "$REGION" 2>/dev/null)

if [ "$SG_ID" = "None" ]; then
  echo "🪪 Creating security group: $SECURITY_GROUP_NAME"
  VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[0].VpcId" --output text --region "$REGION")
  SG_ID=$(aws ec2 create-security-group \
    --group-name "$SECURITY_GROUP_NAME" \
    --description "Security group for SSH access" \
    --vpc-id "$VPC_ID" \
    --region "$REGION" \
    --query "GroupId" --output text)

  # Add SSH access rule
  aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp --port 22 --cidr 0.0.0.0/0 \
    --region "$REGION"
else
  echo "✅ Security group exists: $SG_ID"
fi

# === Step 3: Launch EC2 instance ===
echo "🖥️ Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --count 1 \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SG_ID" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --region "$REGION" \
  --query "Instances[0].InstanceId" \
  --output text)

echo "⏳ Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"

# === Step 4: Get public IP ===
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --region "$REGION" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "✅ EC2 Instance launched successfully!"
echo "Instance ID: $INSTANCE_ID"
echo "Public IP: $PUBLIC_IP"
echo "You can SSH into it using:"
echo "ssh -i ${KEY_NAME}.pem ubuntu@${PUBLIC_IP}"
echo "⏳ Waiting a bit for SSH to be ready..."
sleep 90

