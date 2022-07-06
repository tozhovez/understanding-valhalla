import os
import subprocess
from subprocess import DEVNULL
import json
from datetime import datetime
import msgpack


def config_from_file(config, path, set_in_env=True):
    if path is None:
        return config
    if not os.path.exists(path):
        return config
    try:
        file = open(path, "r")
    except IOError:
        return config

    raw = json.loads(file.read())
    file.close()

    for k in raw.keys():
        if k in config:
            config[k] = raw[k]
            if set_in_env:
                os.environ[k] = str(raw[k])

    return config


def config_from_env(config, prefix=''):
    for k in config.keys():
        key = "%s_%s" % (prefix, k)
        if key.upper() in os.environ:
            config[k] = os.environ[key.upper()]
    return config



def encode_datetime(obj):
    if isinstance(obj, datetime):
        obj = {'__datetime__': True, 'as_str': obj.strftime("%Y%m%dT%H:%M:%S.%f").encode()}
    return obj


def decode_datetime(obj):
    if '__datetime__' in obj:
        obj = datetime.strptime(obj['as_str'], "%Y%m%dT%H:%M:%S.%f")
    return obj


def packb(msg: dict):
    return msgpack.packb(msg, default=encode_datetime)


def unpackb(msg: bytes):
    return msgpack.unpackb(msg, raw=False, object_hook=decode_datetime)


def to_json(obj, pretty = False):
    indent = None
    sort_keys = False
    if pretty:
        indent = 4
        sort_keys = True

    return json.dumps(obj, default=date_to_json, indent=indent, sort_keys=sort_keys)


def date_to_json(date):
    if isinstance(date, datetime):
        return date.isoformat()
    

def get_git_hash_version():

    try:
        version = os.environ.get('VERSION')
        if not version:
            version = subprocess.check_output(
                ["git", "log", "-1", "--pretty=format:%h", "--",
                 "."], stderr=DEVNULL).decode("utf-8")
        return str(version)
    except Exception as ex:
        return 0
