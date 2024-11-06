# frozen_string_literal: true

require_relative "../app/logical/current_user"

module Danbooru
  class Configuration
    # If true, new accounts will require email verification if they seem
    # suspicious (they were created using a proxy, multiple accounts were
    # created by the same IP, etc).
    #
    # This doesn't apply to personal or development installs running on
    # localhost or the local network.
    #
    # Disable this if you're running a public booru and you don't want email
    # verification for new accounts.
    def new_user_verification?
      false
    end

    # Maximum size of an upload. If you change this, you must also change `client_max_body_size` in your nginx.conf.
    def max_file_size
      512.megabytes
    end

    # Maximum duration of an video in seconds.
    def max_video_duration
      # 1h30m
      5400
    end

    # The path to where uploaded files are stored. You can change this to change where files are
    # stored. By default, files are stored like this:
    #
    # * /original/94/43/944364e77f56183e2ebd75de757488e2.jpg
    # * /sample/94/43/sample-944364e77f56183e2ebd75de757488e2.jpg
    # * /180x180/94/43/944364e77f56183e2ebd75de757488e2.jpg
    #
    # A variant is a thumbnail or other alternate version of an uploaded file; see the Variant class
    # in app/models/media_asset.rb for details.
    #
    # This path is relative to the `base_dir` option in the storage manager (see the `storage_manager` option below).
    def media_asset_file_path(variant)
      # md5 = variant.md5
      # file_prefix = "sample-" if variant.type == :sample
      # "/#{variant.type}/#{md5[0..1]}/#{md5[2..3]}/#{file_prefix}#{md5}.#{variant.file_ext}"
      #
      # To store files in this format: `/original/944364e77f56183e2ebd75de757488e2.jpg`
      # "/#{variant.type}/#{variant.md5}.#{variant.file_ext}"
      #
      # To store files in this format: `/original/iuQRl7d7n.jpg`
      "/#{variant.type}/#{variant.file_key}.#{variant.file_ext}"
      #
      # To store files in this format: `/original/12345.jpg`
      # "/#{variant.type}/#{variant.id}.#{variant.file_ext}"
    end

    # The URL where uploaded files are served from. You can change this to customize how images are
    # served. By default, files are served from the same location where they're stored.
    #
    # `custom_filename` is an optional tag string that may be included in the URL. It requires Nginx
    # rewrites to work (see below), so it's ignored by default.
    #
    # The URL is relative to the `base_url` option in the storage manager (see the `storage_manager` option below).
    def media_asset_file_url(variant, custom_filename)
      custom_filename = "__#{custom_filename}__" if custom_filename.present?
      "/#{variant.type}/#{custom_filename}#{variant.file_key}.#{variant.file_ext}"
    end

    # Whether the Gold account upgrade page should be enabled.
    def user_upgrades_enabled?
      false
    end

    # Whether to enable API rate limits.
    def rate_limits_enabled?
      false
    end

    # Whether to enable comments.
    def comments_enabled?
      false
    end

    # Whether to enable the forum.
    def forum_enabled?
      false
    end

    # Whether to enable autocomplete.
    def autocomplete_enabled?
      true
    end
  end
end
