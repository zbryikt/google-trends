require! <[request fs bluebird]>

get-trend = (keyword) ->

get-trends = (list, hash, res, rej) ->

trend = do
  # callback: {keyword, value}
  init: (data) ->
    if !data => data = fs.read-file-sync \curl .toString!
    ret = /-H 'cookie: ([^']+)'/.exec data
    if !ret => @config = {}
    else => @config = {cookie: ret.1}

  get: (keyword) ->
    if !@config => @init!
    (res, rej) <~ new bluebird _
    (e,r,b) <~ request {
      url: "http://www.google.com/trends/fetchComponent?q=#{encodeURIComponent(keyword)}&cid=TIMESERIES_GRAPH_0&export=3"
      method: \GET
      headers: @config
    }, _
    if e or !b => return rej null
    ret = /\{"v":([0-9.]+),"f":"[0-9.]+"\}\]\}\]\}\}\);/.exec b
    value = if !ret => 0 else parseFloat(ret.1)
    res {keyword, value}

  _getAll: (list, hash, res, rej) ->
    if list.length == 0 => return res hash
    tag = list.splice 0,1
    @get tag .then ({keyword, value}) ~> 
      hash[keyword] = value
      @_getAll list, hash, res, rej
    .catch rej

  getAll: (list) -> new bluebird (res, rej) ~>
    @_getAll list, {}, res, rej

module.exports = trend
