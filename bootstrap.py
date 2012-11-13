#!/usr/bin/env python

import os
import stat

try:
    from urllib.request import urlretrieve
except:
    from urllib import urlretrieve

urlretrieve('http://waf.googlecode.com/files/waf-1.7.5', 'waf')
os.chmod('waf', os.stat('waf').st_mode | stat.S_IXUSR)
