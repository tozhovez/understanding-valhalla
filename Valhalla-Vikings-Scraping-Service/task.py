import asyncio
from dataclasses import dataclass

@dataclass
class Task:
    tid: int

    async def perform(self, pool):
        print('start perform', self.tid)
        await asyncio.sleep(10)
        print('complete perform', self.tid)
    
    def parser_html(self, ):
        for img in soup.find_all('img', src=True):
            if img['src'] and img['src'].startswith("https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites") and img['src'].endswith(".jpg?w=840"):
                if img['src'] in PARSED_IMAGES:
                    continue
                PARSED_IMAGES.add(img['src'])
                
                img_folder = pathlib.Path(__file__).parent / "images" /f"{img['src'].removeprefix('https://cropper.watch.aetnd.com/cdn.watch.aetnd.com/sites').removesuffix('?w=840').replace('/','_')}"
                page = requests.get(img['src'])
                with open(img_folder, "wb") as fw:
                    fw.write(page.content)
        
    