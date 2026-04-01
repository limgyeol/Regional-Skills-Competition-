import json
import logging
import pymysql
from pymysql.cursors import DictCursor

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

DB_CONFIG = {
    "user":        "admin",
    "password":    "Skill53##",
    "host":        "skills-storage-rds-instance.chs8yo2w68v0.ap-northeast-2.rds.amazonaws.com",
    "port":        3306,
    "database":    "skills",
    "charset":     "utf8mb4",
    "cursorclass": DictCursor,
}


def get_db_connection():
    return pymysql.connect(**DB_CONFIG)


def resp(status_code: int, body: dict) -> dict:
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body, ensure_ascii=False),
    }


def handle_user(method: str, event: dict) -> dict:
    connection = None
    try:
        if method == "POST":
            body    = json.loads(event.get("body") or "{}")
            name    = body.get("name")
            age     = body.get("age")
            country = body.get("country")

            if not all([name, age, country]):
                return resp(400, {"error": "Required fields missing"})

            connection = get_db_connection()
            with connection.cursor() as cursor:
                cursor.execute(
                    "INSERT INTO users (name, age, country) VALUES (%s, %s, %s)",
                    (name, age, country),
                )
                connection.commit()
            return resp(200, {"message": "User created successfully"})

        elif method == "GET":
            params = event.get("queryStringParameters") or {}
            name   = params.get("name")
            age    = params.get("age")

            if not name or not age:
                return resp(400, {"error": "Query parameters missing"})

            connection = get_db_connection()
            with connection.cursor() as cursor:
                cursor.execute(
                    "SELECT name, age, country FROM users WHERE name = %s AND age = %s",
                    (name, age),
                )
                result = cursor.fetchone()
            return resp(200, result if result else {})

        elif method == "DELETE":
            params = event.get("queryStringParameters") or {}
            name   = params.get("name")
            age    = params.get("age")

            if not name or not age:
                return resp(400, {"error": "Query parameters missing"})

            connection = get_db_connection()
            with connection.cursor() as cursor:
                cursor.execute(
                    "DELETE FROM users WHERE name = %s AND age = %s",
                    (name, age),
                )
                connection.commit()
            return resp(200, {"message": "User deleted successfully"})

        else:
            return resp(405, {"error": "Method not allowed"})

    except Exception as e:
        logger.error(f"DB error: {e}")
        return resp(500, {"error": "Internal server error"})
    finally:
        if connection:
            connection.close()


def lambda_handler(event, context):
    path   = event.get("path") or event.get("rawPath") or ""
    method = (
        event.get("httpMethod")
        or event.get("requestContext", {}).get("http", {}).get("method")
        or "GET"
    ).upper()

    logger.info(f"[{method}] {path}")

    if path == "/v1/user":
        return handle_user(method, event)

    else:
        return resp(404, {"error": "Not found"})