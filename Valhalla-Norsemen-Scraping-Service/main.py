import asyncio
from pool import Pool
from task import Task
from fetch_task import FetchTask, URL


async def start(pool):
    await pool.put(
        FetchTask(url=URL('https://www.imdb.com/title/tt5905354/'), depth=0, tid=1)
    )
    pool.start()
    await pool.join()
    await pool.stop()


def main():
    loop = asyncio.get_event_loop()
    pool = Pool(8)
    try:
        loop.run_until_complete(start(pool))
    except KeyboardInterrupt:
        loop.run_until_complete(pool.stop())
        loop.close()
        


if __name__ == '__main__':
    main()