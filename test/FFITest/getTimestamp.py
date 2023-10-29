from sys import argv
from eth_abi import encode
from datetime import datetime
import pytz

month = int(argv[1])
day = int(argv[2])
year = int(argv[3])
hour = int(argv[4])
minute = int(argv[5])
second = int(argv[6])

utc = pytz.timezone("UTC")

timestamp = int(datetime(year,month,day,hour,minute,second, tzinfo=utc).timestamp())

timestamp = "0x" + encode(["uint256"], [timestamp]).hex()

print(timestamp)
