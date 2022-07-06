import aioredis
import asyncio
from typing import List
from utils import packb, unpackb
from tenacity import retry, stop_after_attempt, wait_fixed, retry_if_exception_type


CONN_ERRORS = (
    ConnectionRefusedError,
    ConnectionError,
    ConnectionAbortedError,
    ConnectionResetError,
    aioredis.ChannelClosedError,
    aioredis.ConnectionClosedError,
    aioredis.ConnectionForcedCloseError,
    aioredis.MaxClientsError
)


class AsyncRedisClient(object):
    DEFAULT_TTL = 60 * 10

    def __init__(self, addr: str, port: int = 6379, db: int = 0):
        self.addr = addr
        self.port = port
        self.url = f'redis://{addr}:{port}'
        self.db = db
        self.client: aioredis.Redis = None

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(5)
        )
    async def connect(self):
        self.client = await aioredis.create_redis_pool(
            self.url, timeout=5, maxsize=1
            )

    async def close(self):
        if self.client:
            self.client.close()
            await self.client.wait_closed()

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(2)
        )
    async def delete(self, key: str):
        await self.client.delete(key)

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(2)
        )
    async def set(self, key: str, value, expire: float = 60 * 10):
        await self.client.set(key, packb(value), expire=expire)

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(2)
        )
    async def get(self, key: str):
        res = None
        res = await self._get_one_and_unpack(key)
        return res

    async def _get_one_and_unpack(self, key):
        res = None
        value = await self.client.get(key)
        if value:
            res = unpackb(value)
        return res

    async def _keys(self, pattern: str):
        return await self.client.keys(pattern)

    async def _scan(self, pattern: str):
        keys = []
        cur = b'0'  # set initial cursor to 0
        while cur:
            cur, current_keys = await self.client.scan(cur, match=pattern)
            keys += current_keys

        return keys

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(2))
    async def get_by_key_pattern(
        self, pattern: str, block_server: bool = True
        ):
        result = []

        keys = []

        if block_server:
            keys = await self._keys(pattern)
        else:
            keys = await self._scan(pattern)
        get_tasks = []
        for key in keys:
            get_tasks.append(self._get_one_and_unpack(key))
        result = await asyncio.gather(*get_tasks, return_exceptions=True)
        return result

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(2)
        )
    async def left_push(self,
                        key: str,
                        values: list,
                        expire: float = 10 * 60):
        values = [packb(value) for value in values]

        await self.client.lpush(key, *values)

        await self.client.expire(key, expire)

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(2)
        )
    async def right_push(self,
                         key: str,
                         values: list,
                         expire: float = 10 * 60):
        values = [packb(value) for value in values]

        await self.client.rpush(key, *values)

        await self.client.expire(key, expire)

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(2)
        )
    async def trim(self,
                   key: str,
                   start: int,
                   stop: int) -> list:
        return await self.client.ltrim(key, start, stop)

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(2)
        )
    async def list_head(self,
                        key: str,
                        n: int) -> list:
        return await self.list_range(key, 0, n - 1)

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(2)
        )
    async def list_tail(self,
                        key: str,
                        n: int) -> list:
        return await self.list_range(key, -n, -1)

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(2)
        )
    async def list_range(self,
                         key: str,
                         start: int,
                         stop: int) -> list:
        items = await self.client.lrange(key, start, stop)

        items = [unpackb(item) for item in items]

        return items

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(2)
        )
    async def length(self,
                     key: str) -> int:
        return await self.client.llen(key)

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(2)
        )
    async def multi_get(self,
                        keys: List[str]):
        res = {}

        values = await self.client.mget(*keys)

        i = 0
        for value in values:
            decoded_value = None
            if value is not None:
                decoded_value = unpackb(value)

            res[keys[i]] = decoded_value

            i = i + 1

        return res

    @retry(
        stop=stop_after_attempt(5),
        retry=retry_if_exception_type(CONN_ERRORS),
        wait=wait_fixed(2)
        )
    async def multi_set(self, items: dict):
        pairs = []

        for key, value in items.items():
            pairs.append(key)
            pairs.append(packb(value))

        await self.client.mset(*pairs)


if __name__ == "__main__":
    async def main():
        client = AsyncRedisClient('localhost')
        await client.connect()

        await client.multi_set({
            'a': 1,
            'b': 2,
            'c': 3
        })

        res = await client.multi_get(['b', 'aaaa', 'c'])
        print(res)

    asyncio.run(main())