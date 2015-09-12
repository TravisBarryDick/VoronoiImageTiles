define ["RandUtils"], (ru) ->

  class AliasTable
    constructor: (@prob, @alias) ->
    sample: ->
      bin = ru.random_int @prob.length
      if ru.random_bool @prob[bin] then bin else @alias[bin]

  make_alias_table = (ps) ->
      n = ps.length
      total = 0
      for p in ps
        total += p
      ps = (p / total * n for p in ps)

      prob = (0 for ix in [0...n])
      alias = (0 for ix in [0...n])

      # Make the small and large working lists
      small = []
      large = []
      for ix in [0...n]
        if ps[ix] < 1.0 then small.push ix else large.push ix

      while small.length > 0 && large.length > 0
        l = small.pop()
        g = large.pop()
        prob[l] = ps[l]
        alias[l] = g
        ps[g] = ps[g] - (1.0 - ps[l])
        if ps[g] < 1.0 then small.push g else large.push g

      prob[g] = 1.0 for g in large
      return new AliasTable prob, alias

  return {make_alias_table: make_alias_table}
