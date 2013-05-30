# 0.0.4 (May 30, 2013)
## fixed
* `to_slug` method not skip nil in path

# 0.0.3 (March 04, 2013)
## added
* config for allowing or disabling caching
* `to_slug_was` for getting old values of object `to_slug`
* `to_slug_will` for getting future values of object `to_slug`
* options for specifying string formatting method
* options for enabling or disabling cacing slugs for tree

# 0.0.3.beta (December 27, 2012)
## changed
* skip cache in tree
## fixed
* tests and schema for appropriate testing

# 0.0.2 (December 5, 2012)
## fixed
* fill in slug from name parameter if slug.parameterize is blank

# 0.0.1 (October 11, 2012)
## added
* init version from real project
* support for storing seo friendly url
* caching slug for ancestry models
* all covered with tests