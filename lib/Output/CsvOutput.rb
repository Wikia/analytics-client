require 'csv'

class CsvOutput
	def initialize( filename )
		@filename = ( filename.include? '.csv' ) ? filename : filename + '.csv'
	end

	def save( data, prefix = '' )
		prefix = prefix + '_' unless prefix == ''

		if data.respond_to? :each
			CSV.open( prefix + @filename , 'wb' ) { |csv|
				csv << data.shift

				data.each { |value|
					csv << value
				}
			}
		else
			$log.error "\t\t\tCorrupt data"
		end
	end
end