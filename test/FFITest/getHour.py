from sys import argv
from datetime import datetime
import pytz
from eth_abi import encode

utc_timezone = pytz.timezone('UTC')

y = int(argv[1])

y = "0x" + encode(["uint8"],[datetime.fromtimestamp(y, tz=utc_timezone).hour]).hex()

print(y)