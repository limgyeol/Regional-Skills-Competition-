#!/bin/bash
dnf update -y
dnf upgrade -y
dnf install --allowerasing -y jq curl wget unzip vim amazon-cloudwatch-agent python3-pip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

sed -i "s|PasswordAuthentication no|PasswordAuthentication yes|g" /etc/ssh/sshd_config
systemctl restart sshd
echo 'Skill53##' | passwd --stdin ec2-user
echo 'Skill53##' | passwd --stdin root

S3_BUCKET_NAME=$(aws s3api list-buckets --query "Buckets[?contains(Name, 'skills-app-storage')].Name" --output text)
aws s3 cp s3://$S3_BUCKET_NAME/main.pyc /home/ec2-user/main.pyc
aws s3 cp s3://$S3_BUCKET_NAME/requirements.txt /home/ec2-user/requirements.txt
pip3 install -r /home/ec2-user/requirements.txt

chown ec2-user:ec2-user /home/ec2-user/main.pyc
chown ec2-user:ec2-user /home/ec2-user/requirements.txt

touch /home/ec2-user/main.log
chown ec2-user:ec2-user /home/ec2-user/main.log
nohup sh -c "python3 /home/ec2-user/main.pyc 2>&1 | grep --line-buffered -Ev 'healthcheck'" > /home/ec2-user/main.log &

timedatectl set-timezone Asia/Seoul
touch /var/log/login.log
chmod 644 /var/log/login.log
chown ec2-user:ec2-user /var/log/login.log

cat <<\EOF> /etc/profile.d/login.sh
#!/bin/bash
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
USER_NAME=$(whoami)

echo "$TIMESTAMP - $USER_NAME accessed this server" >> /var/log/login.log
EOF

chmod +x /etc/profile.d/login.sh

cat << EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/login.log",
            "log_group_name": "skills/ec2/login",
            "log_stream_name": "skills_ec2_{instance_id}",
            "retention_in_days": 7
          },
          {
            "file_path": "/home/ec2-user/main.log",
            "log_group_name": "skills/asg/application",
            "log_stream_name": "skills_app_{instance_id}",
            "retention_in_days": 7
          }
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json