import asyncio
from dataclasses import dataclass
from typing import Optional
from task import Task
from logging import Logger
from datetime import datetime
from injector import singleton, inject
@singleton
class Pool:
    """  Pool the entity controls the number of requests per unit of time
    max_rate:  maximum number of requests
    interval: interval
    concurrent_level: indicates the allowed number of concurrent requests
    scheduler: wake up every interval
               and set the number of tasks equal to max_rate
    """
    @inject
    def __init__(self,
                 #logger: Logger,
                 max_rate: int,
                 interval: int = 10,
                 concurrent_level: Optional[int] = None):
        #self.logger = logger
        self.max_rate = max_rate
        self.interval = interval
        self.concurrent_level = concurrent_level
        self.is_running = False
        self._queue = asyncio.Queue()
        self._scheduler_task: Optional[asyncio.Task] = None
        self._sem = asyncio.Semaphore(concurrent_level or max_rate)
        self._cuncurrent_workers = 0
        self._stop_event = asyncio.Event()

    
    async def _scheduler(self):
        while self.is_running:
            for _ in range(self.max_rate):
                async with self._sem:
                    task = await self._queue.get()
                    asyncio.create_task(self._worker(task))
            await asyncio.sleep(self.interval)
  
    
    async def _worker(self, task: Task):
        async with self._sem:
            self._cuncurrent_workers += 1
            await task.perform(self)
            self._queue.task_done()
        self._cuncurrent_workers -= 1
        if not self.is_running and self._cuncurrent_workers == 0:
            self._stop_event.set()
            
            
    def start(self):
        self.is_running = True
        self._scheduler_task = asyncio.create_task(self._scheduler())
        #self.logger.info("service has started")
    
    
    async def put(self, task: Task):
        await self._queue.put(task)
    
    
    async def join(self):
        await self._queue.join()
    
    
    async def stop(self):
        self.is_running = False
        self._scheduler_task.cancel()
        if self._cuncurrent_workers != 0:
            await self._stop_event.wait()
        #self.logger.info('Job done')
    
    # async def stop(self):
    #     self.is_running = False
    #     self._scheduler_task.cancel()
        
   