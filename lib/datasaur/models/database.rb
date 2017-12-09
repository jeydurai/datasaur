# Databases connection
require 'mongo'

Mongo::Logger.logger.level = ::Logger::FATAL

class MongoBase

  def initialize host, port, dbname, collname
    @host, @port, @dbname, @collname = host, port, dbname, collname
    @client = Mongo::Client.new(["#{@host}:#{@port}"], database: dbname, max_pool_size: 200)
    @coll   = @client[collname.to_sym]
    @data   = nil
  end

  def agg qry
    @coll.aggregate(qry).each do |doc|
      yield(doc)
    end
  end

  def find_doc qry, hideable: { '_id' => 0 }
    @coll.find(qry).projection(hideable).each do |doc|
      yield(doc)
    end
  end
end
