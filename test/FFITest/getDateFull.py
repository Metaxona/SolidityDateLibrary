from sys import argv
from datetime import datetime
import pytz
from eth_abi import encode

utc_timezone = pytz.timezone('UTC')

y = int(argv[1])

date = datetime.fromtimestamp(y, tz=utc_timezone)

y = "0x" + encode(["uint8", "uint8", "uint16", "uint8", "uint8", "uint8"],[date.month, date.day, date.year, date.hour, date.minute, date.second]).hex()

print(y)