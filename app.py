from flask import Flask, abort, render_template, request
from flask.ext import restful
from flask.ext.restful import Api, Resource, reqparse, fields, marshal
from flask_restful_extend import support_jsonp
from flask.ext.sqlalchemy import SQLAlchemy
from sqlalchemy.sql import select, or_, and_, text
from sqlalchemy.engine import reflection
from json import dumps
import requests
from requests.exceptions import RequestException
import logging
import os
import config
import re
import sqlparse


WHITELISTED_KEYWORDS = ['SELECT', 'FROM', 'AS', 'JOIN', 'WITHOUT',
                        'ON', 'TIME', 'ZONE', 'TIMESTAMP', 'LIMIT']

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
api = restful.Api(app)
support_jsonp(api)
db = SQLAlchemy(app)


class DBAPISchema(restful.Resource):

    def __init__(self):
        super(DBAPISchema, self).__init__()

    def get(self, database=None, table=None):
        app.logger.debug("All Headers:  %s", repr(request.headers))
        app.logger.debug("Requested DB:  %s", repr(database))
        app.logger.debug("Default media type:  %s", repr(api.default_mediatype))

        # listing Databases
        if database == None:
            out = [{'name': r, 'description': r} for r in app.config['SQLALCHEMY_BINDS']]
        else:
            if not database in app.config['SQLALCHEMY_BINDS']:
                abort(404, 'Database not found')
            # listing tables
            insp = reflection.Inspector.from_engine(db.get_engine(app, database))
            out = [{'name': r['name'], 'description': r['name'], 'type': r['type']} for r in ([{'name': t, 'type': 'table'} for t in insp.get_table_names()] + [{'name': v, 'type': 'view'} for v in insp.get_view_names()])]

            # list table fields or view definition
            if not table == None:
                d = [r for r in out if r['name'] == table]
                app.logger.debug("ddl:  %s", repr(d))
                if not len(d) == 1:
                    abort(404, 'Database or Table (or View) not found')
                d = d[0]
                if d['type'] == 'table':
                    out = [{'name': r['name'], 'description': r['name'], 'type': repr(r['type']), 'default': r['default'], 'nullable': r['nullable'], 'autoincrement': r['autoincrement']} for r in insp.get_columns(table)]
                else:
                    out = [{'name': table, 'description': insp.get_view_definition(table), 'type': 'view', 'default': '', 'nullable': False, 'autoincrement': False}]
        return out


class DBAPIQuery(restful.Resource):

    def __init__(self):
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument('sql', type=str, default='', help='SQL Query')
        super(DBAPIQuery, self).__init__()

    def get(self, database):
        app.logger.debug("All Headers:  %s", repr(request.headers))
        args = self.reqparse.parse_args()
        app.logger.debug("All parameters:  %s", repr(args))
        app.logger.debug("Default media type:  %s", repr(api.default_mediatype))

        if not database in app.config['SQLALCHEMY_BINDS']:
            abort(404, 'Database not found')

        q = args['sql']
        app.logger.debug("Query:  %s", repr(q))

        if not q:
            abort(400, 'Bad Request (empty query)')

        # do some basic elimination - remove multi-line and no ;
        q = re.sub('[\n\r]+', '', q)
        if ';' in q:
            abort(400, 'Bad Request (multi)')
        app.logger.debug("Query:  %s", repr(q))

        p = sqlparse.parse(q)[0]
        if not p.get_type() == 'SELECT':
            abort(400, 'Query not allowed (must be a select)')

        app.logger.debug("Query Type:  %s", repr(p.get_type()))
        kw = list(set([e.value.upper() for e in p.flatten() if str(e.ttype) == 'Token.Keyword']))

        app.logger.debug("Query keywords:  %s", str(kw))
        for e in kw:
            if not e in WHITELISTED_KEYWORDS:
                abort(400, 'Query not allowed (keyword: %s)' % e)

        res = db.get_engine(app, database).execute(q)
        t = [i for i in res.cursor.description]
        cols = []
        for c in res.cursor.description:
            if c.type_code == 1114:
                ctype = 'date'
            elif c.type_code == 23:
                ctype = 'number'
            else:
                ctype = 'string'
            cols.append({'name': c.name, 'type': ctype})
        app.logger.debug("Cols:  %s", repr(cols))
        recs = []
        for r in res.cursor.fetchall():
            row = {}
            for i in range(len(cols)):
                val = str(r[i]) if cols[i]['type'] == 'date' else r[i]
                row[cols[i]['name']] = val
            recs.append(row)
        app.logger.debug("Recs:  %s", repr(len(recs)))
        out = {'records': recs, 'fields': cols}

        return out


##########
# routes #
##########
api.add_resource(DBAPISchema, '/v1/db', '/v1/db/<database>', '/v1/db/<database>/<table>')
api.add_resource(DBAPIQuery, '/v1/query/<database>')

@app.route('/')
def root():
    return app.send_static_file('index.html')

app.logger.info("routes: %s " % str(app.url_map))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port)
