module WWW
  class Mechanize
    ###
    # Chain of responsibility for handling requests
    class Chain
      def initialize(list)
        @list = list
      end

      def handle(request)
        @list.each { |handler|
          handler.handle(self, request)
        }
      end

      class ArgumentValidator
        def handle(ctx, options)
          raise ArgumentError.new("uri must be specified") unless options[:uri]
        end
      end

      class URIParser
        def handle(ctx, options)
          uri = options[:uri]
          unless uri.is_a?(URI)
            uri = uri.to_s.strip.gsub(/[^#{0.chr}-#{126.chr}]/) { |match|
              sprintf('%%%X', match.unpack($KCODE == 'UTF8' ? 'U' : 'c')[0])
            }
            uri = URI.parse(
                    Mechanize.html_unescape(
                      uri.split(/(?:%[0-9A-Fa-f]{2})+|#/).zip(
                        uri.scan(/(?:%[0-9A-Fa-f]{2})+|#/)
                      ).map { |x,y|
                        "#{URI.escape(x)}#{y}"
                      }.join('')
                    )
                  )
          end

          uri.path = '/' if uri.path.length == 0

          if uri.relative?
            raise unless options[:referer] && options[:referer].uri
          end
        end
      end
    end
  end
end
