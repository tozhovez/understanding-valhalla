#!/usr/bin/env python3

import time
from datetime import timedelta

from html.parser import HTMLParser
from urllib.parse import urljoin, urldefrag

from tornado import gen, httpclient, ioloop, queues

base_url = "https://www.history.com/shows/vikings"
concurrency = 10

class URLSeeker(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.urls = []

    def handle_starttag(self, tag, attrs):
        href = dict(attrs).get("href")
        if href and tag == "a":
            self.urls.append(href)

async def get_links_from_url(url):
    """Download the page at `url` and parse it for links.

    Returned links have had the fragment after `#` removed, and have been made
    absolute so, e.g. the URL 'gen.html#tornado.gen.coroutine' becomes
    'http://www.tornadoweb.org/en/stable/gen.html'.
    """
    response = await httpclient.AsyncHTTPClient().fetch(url)
    #print(response)
    print("fetched %s" % url)

    html = response.body.decode(errors="ignore")
    return [urljoin(url, remove_fragment(new_url)) for new_url in get_links(html)]


def remove_fragment(url):
    pure_url, frag = urldefrag(url)
    #print("url %s\n pure_url %s\n, frag %s\n" % (url, pure_url, frag))
    return pure_url


def get_links(html):
    url_seeker = URLSeeker()
    url_seeker.feed(html)
    return url_seeker.urls

async def fetch_url(current_url, q, fetching, fetched, dead):
    if current_url in fetching:
        return

    print("fetching %s" % current_url)
    fetching.add(current_url)
    urls = await get_links_from_url(current_url)
    fetched.add(current_url)

    for new_url in urls:
        # Only follow links beneath the base URL
        if new_url.startswith(base_url):
            await q.put(new_url)


async def worker(q, fetching, fetched, dead):
    async for url in q:
        if url is None:
            return
        try:
            await fetch_url(url, q, fetching, fetched, dead)
        except Exception as e:
            print("Exception: %s %s" % (e, url))
            dead.add(url)
        finally:
            q.task_done()


async def main():
    q = queues.Queue()
    start = time.time()
    fetching, fetched, dead = set(), set(), set()
    await q.put(base_url)

    # Start workers, then wait for the work queue to be empty.
    workers = gen.multi([worker(q, fetching, fetched, dead) for _ in range(concurrency)])
    await q.join(timeout=timedelta(seconds=300))
    assert fetching == (fetched | dead)
    print("Done in %d seconds, fetched %s URLs." % (time.time() - start, len(fetched)))
    print("Unable to fetch %s URLS." % len(dead))

    # Signal all the workers to exit.
    for _ in range(concurrency):
        await q.put(None)
    await workers


if __name__ == "__main__":
    io_loop = ioloop.IOLoop.current()
    io_loop.run_sync(main)
