def lambda_handler(event, context):

    print("S3 File Upload Event Detected!")

    for record in event["Records"]:

        bucket_name = record["s3"]["bucket"]["name"]

        file_name = record["s3"]["object"]["key"]

        file_size = record["s3"]["object"]["size"]

        print("Bucket:", bucket_name)
        print("File Name:", file_name)
        print("File Size:", file_size, "bytes")

    return {
        "statusCode": 200,
        "body": "S3 event processed successfully"
    }