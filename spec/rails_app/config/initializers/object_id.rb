# These extensions override the JSON encodings for BSON::ObjectId. The reason we're
# doing this is because we make heavy use of passing BSON::ObjectIds to Resque workers. Since Resque JSON encodes
# the payload, the object id was being converted to {'$oid' => 'value'} per
# http://api.mongodb.org/ruby/current/BSON/ObjectId.html#as_json-instance_method
# Mongoid::Document#find breaks in that case, so we need the string version of the id.
module BSON
  class ObjectId
    def as_json(*args)
      to_s()
    end

    def to_json(*args)
      MultiJson.encode(as_json())
    end
  end
end
