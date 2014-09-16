    initializer :after_append_asset_paths, 
                :group => :all, 
                :after => :append_assets_path do

      # DO NOT REMOVE: config.assets.paths.unshift
      config.assets.paths.unshift Rails.root.join("vendor", "assets", "angular").to_s
    end

    # DO NOT REMOVE: config.assets.precompile
    config.assets.precompile += ['angular.js', 'angular.css']

