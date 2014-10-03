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
			self.internal_df[column_name]
		end

		self.send :define_singleton_method, column_name.to_s + '=' do |arg|
			self.internal_df[column_name] = arg
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
