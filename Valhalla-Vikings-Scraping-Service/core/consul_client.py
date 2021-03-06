import logging
import json
import consul
from requests.exceptions import ConnectionError
from tenacity import retry, stop_after_delay, retry_if_exception_type

logger = logging.getLogger('valhalla-vikings-scraping-service')
RETRY_DELAY_IN_SECONDS = 5

class KeyNotFoundError(Exception):
    """Raised when the input value is too small"""
    pass


class ConsulConfig(object):
    prefix = None
    kwargs = {}

    def __init__(self, **kwargs):
        if 'prefix' in kwargs:
            self.prefix = kwargs['prefix']
            kwargs.pop('prefix')
        self.kwargs = kwargs
        self.consul_client = consul.Consul(**kwargs)

    def connect(self):
        self.consul_client = consul.Consul(**self.kwargs)

    @retry(
        retry=retry_if_exception_type(ConnectionError),
        stop=stop_after_delay(RETRY_DELAY_IN_SECONDS)
        )
    def get(self, key, prefix=None):

        try:
            _key = self.prefixed_key(prefix, key)
            _, data = self.consul_client.kv.get(_key)

            if not data:
                raise KeyNotFoundError(f'Key: {key} is not found')

            data_as_str = data['Value'].decode('utf-8')
            return json.loads(data_as_str)
        except ConnectionError as ex:
            self.connect()
            raise ex

    @retry(
        retry=retry_if_exception_type(ConnectionError),
        stop=stop_after_delay(RETRY_DELAY_IN_SECONDS)
        )
    def get_all(self):
        try:
            only_kv_data = []
            _, data = self.consul_client.kv.get(key='', recurse=True)
            for item in data:
                value = item['Value']

                if item['Value'] is not None:
                    only_kv_data.append({
                    "Key": item['Key'],
                    "Value": json.loads(value.decode('utf-8'))
                })
                
            return only_kv_data
        except ConnectionError as ex:
            self.connect()
            raise ex
            
    @retry(
        retry=retry_if_exception_type(ConnectionError),
        stop=stop_after_delay(RETRY_DELAY_IN_SECONDS)
        )
    def put(self, key, value, prefix=None):
        try:
            _key = self.prefixed_key(prefix, key)
            dumped_value = json.dumps(value, indent=4)
            self.consul_client.kv.put(_key, dumped_value)
        except ConnectionError as ex:
            self.connect()
            raise ex

    @retry(
        retry=retry_if_exception_type(ConnectionError),
        stop=stop_after_delay(RETRY_DELAY_IN_SECONDS)
        )
    def put_dict(self, value, prefix=None):

        try:
            for key, value in value.items():
                self.put(key, value, prefix)
        except ConnectionError as ex:
            self.connect()
            raise ex

    def prefixed_key(self, prefix, key):

        if prefix:
            key = '{}/{}'.format(prefix, key)
        elif self.prefix:
            key = '{}/{}'.format(self.prefix, key)

        return key

