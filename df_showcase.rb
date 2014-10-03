$LOAD_PATH << '.'
require 'fuzzy_df'

df = DataFrame.new

df.addColumn :x1, [1, 2, 3]
df.addColumn :x2, [0, -2, -7]

p df.x1
p df.x2

df.x1 = [-1, -5, 10]
p df.x1

p df.names
df.names[:x1] = :x3
p df.x1
p df.x3

df.rmColumn :x3
p df.x3
