import sys
import json
import pymysql

connection = None

try:
    connection = pymysql.connect(
        host="",
        user="",
        passwd="",
        db="",
        connect_timeout=3,
    )
except pymysql.MySQLError as e:
    print("Could not connect to MySQL instance.")
    print(e)
    sys.exit()

def insert_data(event):
    # TODO: MySQL table에 insert하는 로직 구현
    # INSERT INTO product VALUES (<product_id>, <name>);
    product_id = ""

    return {"product_id": product_id}

def select_data(event):
    # TODO: product_id를 기반으로 select 하는 로직 구현
    # SELECT product_id, name FROM product WHERE product_id = '<product_id>';
    product_id = ""
    name = ""

    return {"product_id": product_id, "name": name}


def lambda_handler(event, context):
    if event['op'].lower() == 'post':
        result = insert_data(event)
    elif event['op'].lower() == 'get':
        result = select_data(event)'
    return result
