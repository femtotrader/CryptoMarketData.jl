struct PancakeSwap <: AbstractExchange
    base_url::String
    http_options::Dict

    function PancakeSwap()
        new("https://perp.pancakeswap.finance", Dict())
    end
end

struct PancakeSwapCandle <: AbstractCandle
    ts::UInt64
    o::Float64
    h::Float64
    l::Float64
    c::Float64
    v::Float64
end
# TODO - PancakeSwap has more columns.
# I don't personally plan to use them, but I don't want to throw them away either.

function ts2datetime_fn(pancakeswap::PancakeSwap)
    DateTime ∘ unixmillis2nanodate
end

function candle_datetime(c::PancakeSwapCandle)
    unixmillis2nanodate(c.ts)
end

function short_name(pancakeswap::PancakeSwap)
    "pancakeswap"
end

function candles_max(pancakeswap::PancakeSwap; tf=Minute(1))
    1500
end

function get_markets(pancakeswap::PancakeSwap)
    info_url = pancakeswap.base_url * "/fapi/v1/exchangeInfo"
    uri = URI(info_url)
    res = HTTP.get(uri; pancakeswap.http_options...)
    json = JSON3.read(res.body)
    return map(m -> m[:symbol], json[:symbols])
end

function get_candles(pancakeswap::PancakeSwap, market; start, stop, tf=Minute(1), limit::Integer=10)
    symbol = replace(market, r"\W" => s"") |> lowercase
    interval = if tf == Day(1)
        "1d"
    elseif tf == Minute(1)
        "1m"
    else
        "1m"
    end
    q = OrderedDict(
        "interval"     => interval,
        "contractType" => "PERPETUAL",
        "startTime"    => nanodate2unixmillis(NanoDate(start)),
        "endTime"      => nanodate2unixmillis(NanoDate(stop)),
        "limit"        => limit,
        "symbol"       => symbol
    )
    ohlc_url = pancakeswap.base_url * "/fapi/v1/markPriceKlines"
    uri = URI(ohlc_url, query=q)
    res = HTTP.get(uri; pancakeswap.http_options...)
    json = JSON3.read(res.body)
    map(json) do c
        PancakeSwapCandle(
            c[1] % UInt64, # Casting Int64 to UInt64 :: https://discourse.julialang.org/t/casting-int64-to-uint64/33856/4
            pf64(c[2]),
            pf64(c[3]),
            pf64(c[4]),
            pf64(c[5]),
            pf64(c[6])
        )
    end
end

export PancakeSwap
export PancakeSwapCandle
