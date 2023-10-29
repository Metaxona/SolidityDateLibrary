from eth_abi import encode
from sys import argv

y = int(argv[1])
if (y % 400 == 0) or (y % 100 != 0 and y %4 == 0):
    
    x = "0x" + encode(["bool"], [True]).hex()
    print(x)
else:
    x = "0x" + encode(["bool"], [False]).hex()
    print(x)