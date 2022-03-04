import logging
import boto3
from gi.repository import GExiv2


logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

FILE_NAME_KEY = 'file_name'
FILE_TYPE_KEY = 'file_type'

INCOMING_BUCKET = 'test-turbo-incoming'
OUTGOING_BUCKET = 'test-turbo-outgoing'


def lambda_handler(event, context):
    logger.info(f'Handler.lambda_handler::Received the event: {event} with context: {context}')

    s3_object = None
    for record in event['Records']:
        if 'ObjectCreated' in record['eventName']:
            s3_object = record['s3']
            logger.debug('Handling S3 ObjectCreated event')
            handle_file(s3_object['bucket']['name'], s3_object['object']['key'])

    logger.debug(f'Handler.lambda_handler::Handled the event: {event} with context: {context}')
    return 0

def handle_file(bucket: str, s3_key: str):
    path_ending_index: int = s3_key.rfind('/')
    directory = s3_key[:path_ending_index]
    file_name = s3_key[path_ending_index + 1:]
    lambda_path = "/tmp/" + file_name

    # NOTE: Code help from StackOverflow..

    # Load the file from the S3 bucket.
    client = boto3.client('s3')
    file_content = client.get_object(Bucket=bucket, Key=s3_key)["Body"].read()

    # Save the file back on local FS.
    with open(lambda_path, 'w+') as file:
        file.write(new_content)
        file.close()

    # Strip meta information from file.
    exif = GExiv2.Metadata(lambda_path)
    exif.clear_exif()
    exif.clear_xmp()
    exif.save_file()

    # Save the file back to 'OUTGOING_BUCKET/directory/file_name'.
    s3 = boto3.resource("s3")
    s3.meta.client.upload_file(lambda_path, OUTGOING_BUCKET, s3_key)

    # All done..
    return {
        'statusCode': 200,
        'body': json.dumps('file is created in:'+OUTGOING_BUCKET+s3_key)
    }
