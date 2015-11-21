require "active_record"
require "active_support"
require "wnm_support"
require "slugable/version"
require "slugable/has_slug"
require "slugable/formatter/parameterize"
require "slugable/slug_builder/flat"
require "slugable/slug_builder/tree_ancestry"
require "slugable/slug_builder/caching_tree_ancestry"
require "slugable/cache_layer"
require "slugable/railtie" if defined?(Rails)