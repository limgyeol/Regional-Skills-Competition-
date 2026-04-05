API Gateway + RDS + Lambda 변수 지정
```
REGION_CODE="ap-northeast-2"
RDS_PROXY_NAME="skills-rds-proxy"
SECRETS_MANAGER_NAME="skills-rds-secrets"
DB_USER=$(aws secretsmanager get-secret-value --secret-id $SECRETS_MANAGER_NAME --query "SecretString" --output text --region $REGION_CODE | jq -r ".username")
DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id $SECRETS_MANAGER_NAME --query "SecretString" --output text --region $REGION_CODE | jq -r ".password")
DB_HOST=$(aws rds describe-db-proxies --query "DBProxies[?DBProxyName=='$RDS_PROXY_NAME'].Endpoint" --output text --region $REGION_CODE)
DB_PORT=$(aws secretsmanager get-secret-value --secret-id $SECRETS_MANAGER_NAME --query "SecretString" --output text --region $REGION_CODE | jq -r ".port")
DB_NAME=$(aws secretsmanager get-secret-value --secret-id $SECRETS_MANAGER_NAME --query "SecretString" --output text --region $REGION_CODE | jq -r ".dbname")
```

위 명령어 안되면 jq 깔아야 함

```
LAMBDA_NAME="skills-storage-function"
aws lambda update-function-configuration --function-name $LAMBDA_NAME --environment "Variables={DB_USER=$DB_USER,DB_PASSWORD=$DB_PASSWORD,DB_HOST=$DB_HOST,DB_PORT=$DB_PORT,DB_NAME=$DB_NAME}" --region $REGION_CODE > /dev/null
```