require! <[request fs bluebird cheerio]>

trend = do
  # callback: {keyword, value}
  init: (data) ->
    if !data => data = fs.read-file-sync \curl .toString!
    ret = /-H 'cookie: ([^']+)'/.exec data
    if !ret => @config = {}
    else => @config = {cookie: ret.1}

  _related: (keywords, hash, res, rej) ->
    if keywords.length == 0 => return res hash
    keyword = keywords.splice 0,1 .0
    @related keyword .then (h) ~> 
      hash[keyword] = h
      @_related keywords, hash, res, rej
    .catch rej
  related: (keyword) ->
    if typeof(keyword) == "object" and keyword.length => 
      return new bluebird (res, rej) ~> @_related keyword, {}, res, rej
    if !@config => @init!
    (res, rej) <~ new bluebird _
    (e,r,b) <~ request {
      url: "http://www.google.com.tw/trends/trendsReport?hl=zh-TW&q=#{encodeURIComponent(keyword)}&cmpt=q&tz=&tz=&content=1"
      method: \GET
      headers: @config
    }, _
    if e or !b => return rej null
    $ = cheerio.load b
    ret = {}
    for row in $('#TOP_QUERIES_0_0table .trends-table-row')
      name = $(row).find(".trends-bar-chart-name a:first-child").text!trim!
      value = parseInt($(row).find(".trends-hbars-value").text!trim!)
      ret[name] = value
    return res ret

  _recurse: (keyword, hash, depth, lv, used-keyword, res, rej) ->
    @related keyword .then (new-hash) ~> 
      used-keyword.push keyword
      hash <<< new-hash
      list = [k for k of hash]sort((a,b) -> hash[b] - hash[a])
      while list.length
        new-keyword = list.splice(0,1) .0
        if used-keyword.indexOf(new-keyword)==-1 => break
      if used-keyword.indexOf(new-keyword)>=0 or lv >= depth => return res hash
      else => @_recurse new-keyword, hash, depth, lv + 1, used-keyword, res, rej
    .catch rej

  recursive-related: (keyword, depth = 1) ->
    (res, rej) <~ new bluebird _
    @_recurse keyword, {}, depth, 0, [], res, rej

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
      # sometimes we got ...},,{... data which is not valid json!
      b = b.replace(/,,/g,',')
      b = JSON.parse(b)
      keywords = b.table.cols.map(->it.label).splice(1)
      choose = 1
      # sometimes latest data is not available but there is an entry for it with null as value...
      # in this case, use n - 2 instead of n - 1
      if b.table.rows[* - 1].c.1.v == null => choose = 2
      values =  b.table.rows[* - choose].c.map(->it.v).splice(1)
      for k,i in keywords => ret[k] = values[i]
    else => ret = {}

    res ret

  join: (pivot, hash, map) ->
    if !(pivot of map) => return # pivot should in map
    # pivot not in hash: assume it's a empty hash
    if !(pivot of hash) => hash[pivot] = 1
    for k of map => if k != pivot => 
      hash[k] = hash[pivot] * ( map[k] / map[pivot] )

  normalize: (hash) ->
    min = Math.min.apply null, [hash[k] for k of hash]
    for k of hash => hash[k] = parseInt(100 * hash[k] / min) / 100


  _getAllForPivot: (pivot, list, hash, res, rej) ->
    if list.length == 0 => return res hash
    tag = list.splice 0,1 .0
    @get [pivot,tag] .then (map) ~> 
      @join pivot, hash, map
      @_getAllForPivot pivot, list, hash, res, rej
    .catch rej

  getAllForPivot: (pivot, list, hash) ->
    new bluebird (res, rej) ~> @_getAllForPivot pivot, list, hash, res, rej

  _getAll: (list, pivot = null, hash = {}, res, rej) ->
    if list.length == 1 and !pivot => return @get list .then -> res it
    if list.length == 0 and !pivot => return res hash
    if !pivot => pivot = list.splice 0,1 .0
    @getAllForPivot pivot, list, hash
    .then (hash) ~>
      keys = [k for k of hash]
      mins = keys.filter(->hash[it]==0)
      maxs = keys.filter(->hash[it]==Infinity)
      order = [[k,hash[k]] for k in keys].filter(->it.1!=0 and isFinite(it.1))sort((a,b)-> a.1 - b.1)
      minv = order.0
      maxv = order[* - 1]
      if mins.length and minv.0 != pivot => 
        @getAll(mins, minv.0, hash).then ~> 
          if maxs.length and maxv.0 != pivot => 
            @getAll(maxs, maxv.0, hash).then ~> 
              return res hash
            .catch rej
          else return res hash
        .catch rej
      else if maxs.length and maxv.0 != pivot =>
        @getAll(maxs, maxv.0, hash).then ~> 
          return res hash
        .catch rej
      else return res hash
    .catch rej

  getAll: (list, pivot = null, hash = {}) -> 
    new bluebird (res, rej) ~> @_getAll list, pivot, hash, res, rej

  _align: (v, len, float = false,char=" ") -> 
    s = "#v"
    if float => slen = s.indexOf(".")
    if !float or slen<0 => slen = s.length
    "#char" * (len - slen) + "#v"

  format: (list) ->
    @getAll list .then (hash) ~> 
      keys = [k for k of hash].sort((a,b)-> hash[b] - hash[a])
      len = Math.max.apply null, keys.map(-> it.length)
      for k in keys => console.log @_align(k, len + 2), @_align(parseInt(hash[k]*100)/100, 6, true)

module.exports = trend
