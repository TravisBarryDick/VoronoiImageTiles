define ->
  random_int = (n) -> Math.floor(Math.random() * n)
  random_bool = (p = 0.5) -> Math.random() <= p
  random_point = (dim, w = (1 for i in [0...dim])) -> (Math.random()*w[i] for i in [0...dim])
  random_points = (dim, n, w) -> (random_point(dim, w) for i in [1..n])

  return {
    random_int: random_int
    random_bool: random_bool
    random_point: random_point
    random_points: random_points
  }
