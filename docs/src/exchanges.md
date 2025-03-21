# Exchanges

## Binance

Status:  Work in Progress

Docs: [klines](https://developers.binance.com/docs/derivatives/coin-margined-futures/market-data/Kline-Candlestick-Data)

I have a preliminary `Binance` struct, and it supports Binance's COIN-M Futures
API.  It works, but to properly support all of Binance's APIs, I'm going to
have to add more structs and rename the current `Binance` struct to something
like `BinanceCMFutures`.  In the end, there may be 4 or 5 exchange types just
for Binance.

Proxies are needed if you're local IP is from a forbidden country.

## Bitget

Status:  Slightly Broken

Docs: [market/candles](https://bitgetlimited.github.io/apidoc/en/mix/#get-candle-data)

I had to use an undocumented API that their trading front-end uses to acquire
1m candles, because their official API only gives you the last 30 days of 1m
candles.  It was working fine for a while, but in early February 2024, its
behavior changed and broke `earliest_candle()`.

The constructor for `Bitget` takes an optional named parameter `type` to
specify which [`productType`](https://bitgetlimited.github.io/apidoc/en/mix/#producttype)
to use.  The default value is `dmcbl`.

```julia-repl
julia> bitget_u = Bitget(;type="umcbl")
Bitget("https://api.bitget.com", "https://www.bitget.com", Dict{Any, Any}(), "umcbl")
```

Proxies are needed if you're local IP is from a forbidden country.

## Bitmex

Status:  DONE

Docs:  [trade/bucketed](https://www.bitmex.com/api/explorer/#!/Trade/Trade_getBucketed)

When running `save!(bitmex, market)`, I strongly advise setting `delay=3.5`.
That'll keep you under the rate limit for unauthenticated users.

One thing I like about this library is that you don't need to be authenticated
to use it.  However, Bitmex gives authenticated users a much better rate limit,
so I'd like to support authentication eventually.

```julia-repl
julia> bitmex = Bitmex()
Bitmex("https://www.bitmex.com", Dict{Any, Any}())
julia> save!(bitmex, "ETHUSD"; delay=3.5) # Add a longer delay for Bitmex.
```

## Bitstamp

Status:  DONE

Docs: [ohlc/:symbol](https://www.bitstamp.net/api/#tag/Market-info/operation/GetMarkets)

This exchange is a valuable source of historical data.  Their "BTC/USD" goes
back all the way to 2011-08-18 which is the longest of any known exchange.

## Bybit

Status:  DONE

Docs: [market/kline](https://bybit-exchange.github.io/docs/api-explorer/v5/market/kline)

The `Bybit` constructor takes an optional `category` parameter that
chooses which of the 3 market categories to use.  The default value is `inverse`,
but `linear` and `spot` can also be specified.

```julia-repl
julia> bybit_spot = Bybit(;category=spot)
Bybit("https://api.bybit.com", Dict{Any, Any}(), "spot")
```

Proxies are needed if you're local IP is from a forbidden country.

(The v5 iteration of their API is one of the nicest I've worked with.)

## PancakeSwap

Status:  DONE*

Docs: [history](https://benchmarks.pyth.network/v1/shims/tradingview/history?symbol=Crypto.BTC/USD&from=1736148379&to=1736238379&resolution=5), [apollox](https://apollox-finance.gitbook.io/apollox-finance/welcome/trading-on-v2/how-to-interact-directly-with-the-contract)

I say it's done, but I'm not totally sure.  Instead of using documentation
(which I couldn't find), I ended up reverse engineering their APIs.  I later
discovered that they look a lot like Binance's APIs, and that helped me take
this to a working state.

This is the only DEX among the currently supported exchanges.
