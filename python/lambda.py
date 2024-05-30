import boto3

def lambda_handler(event: any, context: any):
    dynamodb = boto3.resource("dynamodb")
    table_name = "visitor_table"
    table = dynamodb.Table(table_name)

    visit_count = 0

    response = table.get_item(
        Key={
            "visitor_count":0
        }
    )
    if "Item" in response:
        visit_count = response["Item"]["visitor_count"]

    visit_count += 1

    table.put_item(Item={"visitor_count":visit_count})
                         
    return "Visit count {}".format(visit_count)
                         




