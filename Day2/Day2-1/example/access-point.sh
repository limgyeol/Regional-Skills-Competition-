#!/bin/bash
REGION_CODE="ap-northeast-2"
EFS_NAME="shared-efs"
ACCESS_POINT_NAME="shared-access-point"
MOUNT_DIR="/home/ec2-user/efs"
EFS_ID=$(aws efs describe-file-systems --query "FileSystems[?Name=='$EFS_NAME'].FileSystemId" --output text --region $REGION_CODE)
EFS_ACCESS_POINT=$(aws efs describe-access-points --file-system-id $EFS_ID --query "AccessPoints[?Tags[?Key=='Name' && Value=='$ACCESS_POINT_NAME']].AccessPointId" --output text)

dnf install -y amazon-efs-utils

mkdir -p $MOUNT_DIR
chown ec2-user:ec2-user $MOUNT_DIR

mount -t efs -o tls,accesspoint=$EFS_ACCESS_POINT $EFS_ID $MOUNT_DIR

echo "$EFS_ID:/ $MOUNT_DIR efs defaults,_netdev,accesspoint=$EFS_ACCESS_POINT 0 0" | tee -a /etc/fstab