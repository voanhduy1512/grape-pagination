module Grape::Pagination
  class Paginator
    extend Forwardable

    TOTAL_HEADER = 'X-Total'.freeze
    LINK_HEADER  = 'Link'.freeze

    attr_reader :endpoint
    attr_reader :collection
    attr_reader :options

    def self.paginate(*args)
      new(*args).paginate
    end

    def initialize(endpoint, collection, options = {})
      @endpoint   = endpoint
      @collection = collection
      @options    = options
    end

    def paginate
      header LINK_HEADER, LinkHeader.new(request.url, page_params).to_rfc5988
      if collection.respond_to? :paginate
        collection.paginate(page_params)
      else
        collection.page(page_params[:page]).per(page_params[:per_page])
      end
    end

  private

    def_delegators :endpoint, :header, :params, :request

    def page_params
      @page_params ||= params.slice(:page, :per_page).to_h.symbolize_keys
    end

    def configuration
      Grape::Pagination.configuration
    end

  end
end
