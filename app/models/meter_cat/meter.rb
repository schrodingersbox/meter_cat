# A Meter is simply an integer value for a unique name+date pair

require 'csv'

module MeterCat
  class Meter < ActiveRecord::Base

    validates :name, :presence => true

    ###########################################################################
    # Constants

    CSV_COLUMNS = [ :name, :date, :value ].freeze

    # The expiration time for an in-memory cached meter

    DEFAULT_EXPIRATION = 3600

    # The number of retries in the event of an optimistic locking failure or creation collision

    DEFAULT_RETRY_ATTEMPTS = 5

    # The delay between retries, in seconds.
    # Not using exponential back-off to prevent blocking controllers.
    # Better to lose a little data than create a bad user experience.

    DEFAULT_RETRY_DELAY = 1

    ###########################################################################
    # Instance methods

    # Create an object for this name+date in the db if one does not already exist.
    # Add the value from this object to the one in the DB.
    # Returns the result of the ActiveRecord save operation.

    def add
      meter = Meter.find_by_name_and_created_on( name, created_on )
      meter ||= Meter.new( :name => name, :created_on => created_on )
      meter.value += value
      return meter.save
    end

    # Calls #add with retry logic up to ::MAX_ADD_ATTEMPTS times.
    # Catches ActiveRecord::StaleObjectError and ActiveRecord::RecordNotUnique for retries.
    # Returns the result of the final call to #add

    def add_with_retry
      success = false

      (1..MeterCat.config.retry_attempts).each do
        begin
          break if success = add
        rescue ActiveRecord::StaleObjectError, ActiveRecord::RecordNotUnique
        end
        Kernel.sleep( MeterCat.config.retry_delay )
      end

      return success
    end

    # Determines if the meter is expired and should be flushed from memory to DB

    def expired?
      return ( Time.now - created_at ) > MeterCat.config.expiration
    end

    ###########################################################################
    # Class methods

    # Returns all unique meter names sorted

    def self.names
      Meter.uniq.pluck( :name ).sort
    end

    # Generates a random sequence for a meter given the following args:
    # [ :name, :min, :max, :start, :stop ]

    def self.random( args )
      name = args[ :name ]
      min = args[ :min ].to_i
      max = args[ :max ].to_i
      start = Date.parse( args[ :start ] )
      stop = Date.parse( args[ :stop ] )

      (start .. stop).each do |date|
        value = min + rand( max - min )
        begin
          Meter.create( :name => name, :value => value, :created_on => date )
        rescue
        end
      end
    end

    # Returns a hash of names to dates to values

    def self.to_h( range, names = nil )
      meters = {}

      select_meters( range, names ) do |meter|
        name = meter.name.to_sym
        meters[ name ] ||= {}
        meters[ name ][ meter.created_on ] = meter.value
      end

      return meters
    end

    def self.to_csv( range, names = nil  )
      CSV.generate do |csv|
        csv << CSV_COLUMNS
        select_meters( range, names ) do |meter|
          csv << [ meter.name, meter.created_on, meter.value ]
        end
      end
    end

  protected

    def self.select_meters( range, names )
      conditions = {}
      conditions[ :created_on ] = range if range
      conditions[ :name ] = names if names

      Meter.select( 'name,created_on,value' ).where( conditions ).find_each do |meter|
        yield meter
      end
    end

  end
end
