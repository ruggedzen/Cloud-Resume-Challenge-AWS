import boto3, json

dynamodb = boto3.client("dynamodb")
table = "swnl_stats_test"

def lambda_handler(event: any, context: any):
    response = dynamodb.update_item(
        TableName = table,
        Key={'metric': {'S':'view_count'}},
        UpdateExpression="ADD num :val",
        ExpressionAttributeValues={':val':{"N" : "1"}},
        ReturnValues="UPDATED_NEW"
    )
    
    lambdaResponse = {
        'statusCode': json.dumps(response["ResponseMetadata"]["HTTPStatusCode"]),
        'body': json.dumps(response["Attributes"]["num"]["N"]),
        'headers' : {
            'Access-Control-Allow-Origin' : '*'
        }
    }
    
    return lambdaResponse
    
