import os
import urllib3
import json
import sys

def lambda_handler(event, context):

    print(os.environ["REQUESTS_CA_BUNDLE"])

    ca_certificate = open(os.environ["REQUESTS_CA_BUNDLE"], "r").read()
    print(ca_certificate)

    body = json.loads(event["body"])
    r_url = body["url"]
    print(r_url)

    r_body = "empty"
    r_status_code = 0
    http = urllib3.PoolManager(ca_certs=os.environ["REQUESTS_CA_BUNDLE"])

    try:
        r = http.request("GET", r_url)
        print(r.status)
        print(r.data)
        r_body = r.data
        r_status_code = r.status
    except:
        print("Unexpected error:", sys.exc_info()[0])
        r_body = sys.exc_info()[0]
        r_status_code = 500

    response = {
		"statusCode": 200,
		"statusDescription": "200 OK",
		"isBase64Encoded": False,
		"headers": {
			"Content-Type": "text/plain; charset=utf-8"
	    }
	}

    response['body'] = r_body

    # Return response
    return response
