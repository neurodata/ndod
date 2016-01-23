from distutils.core import setup
import ndod

VERSION = ndod.version

setup(
    name = 'ndod',
    packages = [
        'ndod'
    ],
    version = VERSION,
    description = 'A Python library for NeuroData object detection',
    author = 'William Gray Roncal',
    author_email = 'wgr@jhu.edu',
    url = 'https://github.com/willgray/ndod-pip',
    download_url = 'https://github.com/willgray/ndod-pip/tarball/' + VERSION,
    keywords = [
        'NeuroData',
        'object detection',
        'annotation',
        'computer vision'
    ],
    classifiers = [],
)
