# Prerequisite

- Install jq (json processor) at https://stedolan.github.io/jq/download/

# Use

Run it with company name to get google finance comparison url
```
gen-google-finance-comparison-url.sh overstock peloton amazon
```
output: [https://www.google.com/finance/quote/NDAQ:NASDAQ?comparison=NASDAQ:OSTK,NASDAQ:PTON,NASDAQ:AMZN](https://www.google.com/finance/quote/NDAQ:NASDAQ?comparison=NASDAQ:OSTK,NASDAQ:PTON,NASDAQ:AMZN,
)

Other examples:
```
gen-google-finance-comparison-url.sh zoom PTON tesla BTC-USD ETH-USD
gen-google-finance-comparison-url.sh -b BTC-USD LTC-USD ETH-USD #this one sets the base with -b flag
```
