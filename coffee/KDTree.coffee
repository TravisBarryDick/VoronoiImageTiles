define ->

  dist = (p,q) ->
    total = 0.0
    for i in [0...p.length]
      d = p[i] - q[i]
      total += d*d
    return Math.sqrt(total)

  class KDNode
    constructor: (@axis, @pt, @ix, @left, @right) ->

    leaf: -> not @pt?

    depth: -> if @leaf() then 1 else 1 + Math.max(@left.depth(), @right.depth())

    nns: (q, p = null, ix = null, d = Infinity) ->
      if @leaf() then return [p,ix,d]
      signed_margin = q[@axis] - @pt[@axis]
      [f,s] = if signed_margin <= 0 then [@left, @right] else [@right, @left]
      [p,ix,d] = f.nns(q, p, ix, d)
      [p,ix,d] = s.nns(q, p, ix, d) unless d < Math.abs(signed_margin)
      this_d = dist(q, @pt)
      [p,ix,d] = [@pt, @ix, this_d] if this_d < d
      return [p,ix,d]

    draw_on_context: (ctx, lb, ub) ->
      if @leaf() then return
      line_start = lb.slice()
      line_end = ub.slice()

      line_start[@axis] = @pt[@axis]
      line_end[@axis] = @pt[@axis]


      if (not @left.leaf()) or (not @right.leaf())
        ctx.beginPath()
        ctx.moveTo(line_start[0], line_start[1])
        ctx.lineTo(line_end[0], line_end[1])
        ctx.stroke()

      ctx.fillRect(@pt[0]-2, @pt[1]-2, 4, 4)

      left_lb = lb.slice()
      left_ub = ub.slice()

      right_lb = lb.slice()
      right_ub = ub.slice()

      left_ub[@axis] = @pt[@axis]
      right_lb[@axis] = @pt[@axis]

      @left.draw_on_context ctx, left_lb, left_ub
      @right.draw_on_context ctx, right_lb, right_ub

    draw_on_canvas: (cvs) ->
      ctx = cvs.getContext("2d")
      @draw_on_context ctx, [0, 0], [cvs.width, cvs.height]


  intersect = (a, b) ->
    c = []
    for ae in a
      if ae in b then c.push(ae)
    return c

  # This code can be considerably optimized by sorting the points along each
  # axis once at the beginning.
  make_kdtree = (points, ixs = [0...points.length], depth = 0) ->
    n = points.length
    if n == 0
      return new KDNode null, null, null, null, null
    else
      dim = points[0].length
      axis = depth % dim
      sortperm = [0...n]
      sortperm.sort((i,j) -> points[i][axis] - points[j][axis])
      mid = n // 2
      [left_sub, center, right_sub] = [sortperm[0...mid], sortperm[mid], sortperm[(mid+1)...n]]

      left_pts = (points[i] for i in left_sub)
      left_ixs = (ixs[i] for i in left_sub)
      left = make_kdtree left_pts, left_ixs, depth + 1

      center_pt = points[center]
      center_ix = ixs[center]

      right_pts = (points[i] for i in right_sub)
      right_ixs = (ixs[i] for i in right_sub)
      right = make_kdtree right_pts, right_ixs, depth + 1

      return new KDNode axis, center_pt, center_ix, left, right

  return {
    make_kdtree: make_kdtree
  }
