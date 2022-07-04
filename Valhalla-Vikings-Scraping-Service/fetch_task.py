import asyncio
from bs4 import BeautifulSoup
from dataclasses import dataclass
from urllib.parse import urlparse, urlunparse, urljoin, urldefrag
from typing import Set, Union, List, MutableMapping, Optional
from task import Task
import aiohttp

from yarl import URL
MAX_DEPTH = 1000
PARSED_URLS = set()

#<script data-module-id="shared-schema__series" type="application/ld+json">
#dm = soup.find_all('script', attrs={"data-module-id": "shared-schema__series"})
#print(f"DATA-MODULE-ID = {dm}")
#for dscr in soup.find_all(attrs={"class": "description"}):
#    print(f"DESCRIPTION    {dscr.contents}")
        
#for title in soup.find_all('title'):
#    print(f"title= {title.contents}")

@dataclass
class FetchTask(Task):
    url:  URL
    depth: int
    
    
    def parser(self, data: str) -> List['FetchTask']:
        if self.depth + 1 > MAX_DEPTH:
            return []
        soup = BeautifulSoup(data, 'lxml')
        #print(soup)
        res = []
        
        
        for link in soup.find_all(href=True):
            new_url = URL(link['href'])
            
            
            if new_url.host is None and new_url.path.startswith('/'):
                new_url = URL.build(
                    scheme=self.url.scheme,
                    host=self.url.host,
                    path=new_url.path,
                    query_string=new_url.query_string
                )
                if new_url in PARSED_URLS:
                    continue
                if not new_url.path.startswith(self.url.path):
                    continue
                PARSED_URLS.add(new_url)
                
                res.append(FetchTask(
                    tid=self.tid,
                    url=new_url,
                    depth=self.depth + 1
                ))
        return res
    

    async def perform(self, pool):
        async with aiohttp.ClientSession() as session:
            async with session.get(self.url) as resp:
                print(self.url, resp.status)
                data = await resp.text()
                print(data)
                res: List[FetchTask] = await asyncio.get_running_loop().run_in_executor(
                    None, self.parser, data
                )
                for task in res:
                    await pool.put(task)


