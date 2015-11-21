module Slugable
  module Formatter
    class Parameterize
      def self.call(string)
        string.parameterize
      end
    end
  end
end
