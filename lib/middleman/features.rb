# Middleman provides an extension API which allows you to hook into the
# lifecycle of a page request, or static build, and manipulate the output.
# Internal to Middleman, these extensions are called "features," but we use
# the exact same API as is made available to the public.
#
# A Middleman extension looks like this:
#
#     module MyExtension
#       class << self
#         def registered(app)
#           # My Code
#         end
#       end
#     end
#
# In your `config.rb`, you must load your extension (if it is not defined in
# that file) and call `activate`.
#
#     require "my_extension"
#     activate MyExtension
#
# This will call the `registered` method in your extension and provide you
# with the `app` parameter which is a Middleman::Server context. From here
# you can choose to respond to requests for certain paths or simply attach
# Rack middleware to the stack.
#
# The built-in features cover a wide range of functions. Some provide helper
# methods to use in your views. Some modify the output on-the-fly. And some
# apply computationally-intensive changes to your final build files.

module Middleman::Features

  # RelativeAssets allow any asset path in dynamic templates to be either
  # relative to the root of the project or use an absolute URL.
  autoload :RelativeAssets,      "middleman/features/relative_assets"

  # AssetHost allows you to setup multiple domains to host your static assets.
  # Calls to asset paths in dynamic templates will then rotate through each of
  # the asset servers to better spread the load.
  autoload :AssetHost,           "middleman/features/asset_host"

  # CacheBuster adds a query string to assets in dynamic templates to avoid
  # browser caches failing to update to your new content.
  autoload :CacheBuster,         "middleman/features/cache_buster"

  # DefaultHelpers are the built-in dynamic template helpers.
  autoload :DefaultHelpers,      "middleman/features/default_helpers"

  # AutomaticImageSizes inspects the images used in your dynamic templates and
  # automatically adds width and height attributes to their HTML elements.
  autoload :AutomaticImageSizes, "middleman/features/automatic_image_sizes"

  # UglyHaml enables the non-indented output format from Haml templates. Useful
  # for somewhat obfuscating the output and hiding the fact that you're using Haml.
  autoload :UglyHaml,            "middleman/features/ugly_haml"

  # MinifyCss uses the YUI compressor to shrink CSS files
  autoload :MinifyCss,           "middleman/features/minify_css"

  # MinifyJavascript uses the YUI compressor to shrink JS files
  autoload :MinifyJavascript,    "middleman/features/minify_javascript"

  # CodeRay is a syntax highlighter.
  autoload :CodeRay,             "middleman/features/code_ray"

  # Lorem provides a handful of helpful prototyping methods to generate words,
  # paragraphs, fake images, names and email addresses.
  autoload :Lorem,               "middleman/features/lorem"

  # Data looks at the data/ folder for YAML files and makes them available
  # to dynamic requests.
  autoload :Data,                "middleman/features/data"

  # Parse YAML metadata from templates
  autoload :FrontMatter,         "middleman/features/front_matter"
  
  # Treat project as a blog
  autoload :Blog,                "middleman/features/blog"
  
  # Proxy web services requests in dev mode only
  autoload :Proxy,               "middleman/features/proxy"
  
  # Automatically resize images for mobile devises
  # autoload :TinySrc,             "middleman/features/tiny_src"

  # LiveReload will auto-reload browsers with the live reload extension installed after changes
  # Currently disabled and untested.
  # autoload :LiveReload,          "middleman/features/live_reload"

  # The Feature API is itself a Feature. Mind blowing!
  class << self
    def registered(app)
      app.extend ClassMethods
    end
    alias :included :registered
  end

  module ClassMethods
    # This method is available in the project's `config.rb`.
    # It takes a underscore-separated symbol, finds the appropriate
    # feature module and includes it.
    #
    #     activate :lorem
    #
    # Alternatively, you can pass in a Middleman feature module directly.
    #
    #     activate MyFeatureModule
    def activate(feature)
      feature = feature.to_s if feature.is_a? Symbol

      if feature.is_a? String
        feature = feature.camelize
        feature = Middleman::Features.const_get(feature)
      end

      register feature
    end

    # Deprecated API. Please use `activate` instead.
    def enable(feature_name)
      $stderr.puts "Warning: Feature activation has been renamed from enable to activate"
      activate(feature_name)
      super(feature_name)
    end
  end
end
