import boto3

def lambda_handler(event: any, context: any):
    dynamodb = boto3.resource("dynamodb")
    table_name = "visitor_table"
    table = dynamodb.Table(table_name)

    if table.item_count == 0:
        table.put_item(ItemItem={"visitor_count": "N" : "0"})
    else:
        response = table.update_item(
            Key={"visitor_count":"N"},
            UpdateExpression="ADD #cnt :val",
            ExpressionAttributeNames={"#cnt": "count"},   
            ExpressionAttributeValues={':val': 1},
            ReturnValues="UPDATED_NEW"
        )

    visitorCountID - response["Attributes"]["count"]

    table.put_item(
        Item={}
    )





