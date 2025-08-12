#!/bin/bash

# === Configurable variables ===
INSTANCE_NAME="my-lightsail-instance"
REGION="us-east-1"
AVAILABILITY_ZONE="us-east-1a"
BUNDLE_ID="nano_2_0"           # Example: nano_2_0, micro_2_0, small_2_0, medium_2_0, etc.
BLUEPRINT_ID="ubuntu_24_04"    # Example: ubuntu_20_04, amazon_linux_2, etc.

# === Create the instance ===
echo "Creating AWS Lightsail instance: $INSTANCE_NAME in $REGION..."

aws lightsail create-instances \
  --instance-names "$INSTANCE_NAME" \
  --availability-zone "$AVAILABILITY_ZONE" \
  --blueprint-id "$BLUEPRINT_ID" \
  --bundle-id "$BUNDLE_ID" \
  --region "$REGION"

# === Check if it was created successfully ===
if [ $? -eq 0 ]; then
  echo "✅ Lightsail instance '$INSTANCE_NAME' is being created."
else
  echo "❌ Failed to create Lightsail instance. Please check your AWS CLI setup or parameters."
fi
