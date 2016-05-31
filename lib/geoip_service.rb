module Service
  class GeoIPService < CrudService::Service

    def initialize(dal, log)
      super dal, log
    end

    def get_one_by_ip(ip_address)
      @dal.get_one_by_ip(ip_address)
    end

    def valid_insert?(data)
      false
    end

    def valid_update?(data)
      false
    end
  end
end