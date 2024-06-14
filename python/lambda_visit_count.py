import boto3

def lambda_handler(event: any, context: any):
    dynamodb = boto3.client("dynamodb")
    table = "swnl_site_metrics"
    
    response = dynamodb.update_item(
        TableName = table,
        Key={'metric': {'S':'view_count'}},
        UpdateExpression="ADD num :val",
        ExpressionAttributeValues={':val':{"N" : "1"}},
        ReturnValues="UPDATED_NEW"
    )
                         