require! <[request fs bluebird]>

trend = do
  # callback: {keyword, value}
  init: (data) ->
    if !data => data = fs.read-file-sync \curl .toString!
    ret = /-H 'cookie: ([^']+)'/.exec data
    if !ret => @config = {}
    else => @config = {cookie: ret.1}

  get: (keywords) ->
    length = 1
    if Array.isArray(keywords) => 
      length = keywords.length
      keywords = keywords.splice(0,5).join(\,)
    if !@config => @init!
    (res, rej) <~ new bluebird _
    (e,r,b) <~ request {
      url: "http://www.google.com/trends/fetchComponent?q=#{encodeURIComponent(keywords)}&cid=TIMESERIES_GRAPH_0&export=3"
      method: \GET
      headers: @config
    }, _
    if e or !b => return rej null
    mat = /google.visualization.Query.setResponse\((.+)\);/.exec b
    if mat =>
      b = mat.1
      ret = {}
      b = b.replace(/new Date\((\d+),(\d+),(\d+)\)/g,'"$1/$2/$3"')
      b = JSON.parse(b)
      keywords = b.table.cols.map(->it.label).splice(1)
      values =  b.table.rows[* - 1].c.map(->it.v).splice(1)
      for k,i in keywords => ret[k] = values[i]
    else => ret = {}

    res ret

  _getAll: (pivot, list, hash, res, rej) ->
    if list.length == 0 => return res hash
    tag = list.splice 0,1 .0
    @get [pivot,tag] .then (mapper) ~> 
      if !hash[pivot] => hash[pivot] = mapper[pivot]
      hash[tag] = mapper[tag] * hash[pivot] / mapper[pivot]
      @_getAll pivot, list, hash, res, rej
    .catch rej

  getAll: (list) -> 
    pivot = list.splice(0,1) .0
    return if list.length == 0 => @get [pivot]
    else => new bluebird (res, rej) ~>
      @_getAll pivot, list, {}, res, rej

module.exports = trend
