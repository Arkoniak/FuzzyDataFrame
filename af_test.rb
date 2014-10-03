module Columns

	refine Symbol do
		def +(other)
			(self.to_s + other.to_s).to_sym
		end
	end

	def self.included(base)
		base.extend ClassMethods
	end

	def addColumn(column_name, column)
		# self.send :attr_accessor, column_name
		# self.send column_name+'=', column

		self.send :define_singleton_method, column_name do
			internal_df[column_name]
		end

		self.send :define_singleton_method, column_name.to_s + '=' do |arg|
			internal_df[column_name] = arg
		end

		self.send column_name.to_s + '=', column
		
		self.rebuild_names

		# self.class.send :define_method, column_name do
		# 	column
		# end

		# self.class.send :define_method, column_name + '=' do |arg|
			
		# end
	end

	def rmColumn column_name
		self.singleton_class.send :remove_method, column_name
		self.singleton_class.send :remove_method, column_name.to_s + '='
		self.internal_df.delete column_name.to_s
	end

	module ClassMethods

		def addColumn(column_name, column)
			send :define_method, column_name do
				column
			end
		end

		def rmColumn(column_name)
			send :remove_method, column_name
		end
	end
end

class DataFrame
	include Columns
	using Columns
	attr_accessor :internal_df, :names

	def initialize
		self.internal_df = {}
	end
	
	def rebuild_names
		loc_names = self.internal_df.keys
		grand = self
		loc_names.send :define_singleton_method, :[]= do |key, val|
			grand.singleton_class.send :remove_method, key
			grand.singleton_class.send :remove_method, key + '='
			grand.internal_df[val] = grand.internal_df.delete(key)
			grand.send :define_singleton_method, val do
				grand.internal_df[val]
			end

			grand.send :define_singleton_method, val + '=' do |arg|
				grand.internal_df[val] = arg
			end
			
			grand.rebuild_names
		end

		self.names = loc_names
	end
end

df = DataFrame.new
df

df = nil
df.singleton_methods

df.x1
df.x2
df.x3

df.addColumn("x1", [1, 2, 6])
df.x1 = [1, 2, 3]
df.addColumn "x2", [4, 7, 8]
df.rmColumn :x1

df.internal_df
df.singleton_methods

df.x2
df.names
df.names["x1"] = "x3"
df.names["x2"] = "MySuperName"
df.MySuperName

df.singleton_class.remove_method :x1

df.instance_eval do
	def [](key)
		internal_df[key]
	end
end

df['x1']

df2 = DataFrame.new
df2.x3

df2.remove_instance_variable(:x3)
df2.class.remove_method("x3")
df2.singleton_methods
df2.instance_eval { undef x3 }

df2.instance_eval { undef :x3 }

gg = 'x3'.to_sym
df2.instance_eval { send undef, gg }

df2.addColumn 'x3', [1, 5, 7]
df2.x3 = [6, 8, 0]


df3 = DataFrame.new
df3.addColumn 'x3', [1, 2]
df3.x3

df.class
df.public_instance_methods true

df.methods

:x3 + "="

"x3".to_s + "="

DataFrame.public_instance_methods
DataFrame.methods

aa = {}
aa['one'] = [1, 2, 3]
aa['two'] = [5, 6, 7]
aa.delete :one
aa
aa.keys

aa = "asdsadsad="
aa.chop
aa

bb = [4, 8, 0]
bb -= [4]
bb += [7]
bb
bb[bb.index(0)] = 1

:x + :y

class Symbol
	undef +
end
