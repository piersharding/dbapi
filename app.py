from flask import Flask, abort, render_template, request
from flask_restful import Api, Resource, reqparse, fields, marshal
from flask_restful import reqparse
from json import dumps
from urllib.parse import unquote_plus
import json
import requests
from requests.exceptions import RequestException
import logging
import os
import config
import re


##########
# helper #
##########

prefix =  os.environ.get('URL_PREFIX') if  os.environ.get('URL_PREFIX') else ''
port =  int(os.environ.get('FLASK_PORT')) if  os.environ.get('FLASK_PORT') else 5000
app = Flask(__name__, static_url_path=prefix)
app.config.from_object(os.environ['APP_SETTINGS'])
level = logging.DEBUG if app.config['DEBUG'] else logging.ERROR
app.logger.setLevel(level)
app.logger.info("APP_SETTINGS: %s " % os.environ['APP_SETTINGS'])
api = Api(app)


class APIWebhook(Resource):

    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        # self.reqparse.add_argument('sql', type=str, default='', help='SQL Query')
        super(APIWebhook, self).__init__()


    def _parse_request(self, req):
        """
        Parses application/json request body data into a Python dictionary
        """
        payload = req.get_data()
        app.logger.debug("Payload:  %s", repr(payload))
        payload = unquote_plus(payload.decode())
        payload = re.sub('payload=', '', payload)
        try:
            res = json.loads(payload)
        except json.decoder.JSONDecodeError:
            res = payload

        return res

    def post(self):
        app.logger.debug("All Headers:  %s", repr(request.headers))
        args = self.reqparse.parse_args()
        app.logger.debug("All parameters:  %s", repr(args))
        app.logger.debug("Default media type:  %s", repr(api.default_mediatype))
        payload = self._parse_request(request)
        app.logger.debug("Payload:  %s", repr(payload))
        return ("", 200, None)


##########
# routes #
##########
api.add_resource(APIWebhook, '/v1/webhook/')

@app.route('/')
def root():
    return app.send_static_file('index.html')

app.logger.info("routes: %s " % str(app.url_map))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port)
