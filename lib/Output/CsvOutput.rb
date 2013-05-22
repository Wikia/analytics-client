class CsvOutput
	def initialize( data, filename )
		@data = data

		@filename = ( filename.include? '.csv' ) ? filename : filename + '.csv'
	end

	def save
		if @data.respond_to? :each
			CSV.open( @filename , 'wb' ) { |csv|
				csv << @data.shift

				@data.each { |value|
					csv << value
				}
			}
		else
			log 'Corrupt data'
		end
	end
end