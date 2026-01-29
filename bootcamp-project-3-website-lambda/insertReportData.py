import json
import boto3

# Create a DynamoDB object using the AWS SDK
dynamodb = boto3.resource('dynamodb')
# Use the DynamoDB object to select our table
table = dynamodb.Table('btcmp-proj-3-dynmdb')

# Define the handler function that the Lambda service will use as an entry point
def lambda_handler(event, context):
    # Extract values from the event object we got from the Lambda service and store in variables
    inspection_id = event['inspectionid']
    clientname = event['clientname']
    building_class = event['class']
    status = event['status']
    notes = event['notes']

    # Write Inspection Report data to the DynamoDB table and save the response in a variable
    response = table.put_item(
        Item={
            'inspectionid': inspection_id,
            'clientname': clientname,
            'class': building_class,
            'status': status,
            'notes':notes
        }
    )
    
    # Return a properly formatted JSON object
    return {
        'statusCode': 200,
        'body': json.dumps('Inspection Report data saved successfully!')
    }
