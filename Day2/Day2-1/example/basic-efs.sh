#!/bin/bash
REGION_CODE="ap-northeast-2"
EFS_NAME="shared-efs"
MOUNT_DIR="/home/ec2-user/efs"
EFS_ID=$(aws efs describe-file-systems --query "FileSystems[?Name=='$EFS_NAME'].FileSystemId" --output text --region $REGION_CODE)

dnf install -y amazon-efs-utils

mkdir -p $MOUNT_DIR
chown ec2-user:ec2-user $MOUNT_DIR

mount -t efs -o tls $EFS_ID $MOUNT_DIR

echo "$EFS_ID:/ $MOUNT_DIR efs defaults,_netdev 0 0" | tee -a /etc/fstab