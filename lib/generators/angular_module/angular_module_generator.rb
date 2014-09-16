require 'fileutils'

class AngularModuleGenerator < Rails::Generators::NamedBase
  AngularModuleGeneratorError = Class.new(Nesty::NestedStandardError)

  source_root File.expand_path('../templates', __FILE__)

  def initializer
    @_module_capitalized = file_name.singularize.capitalize
    @_module_singular = file_name.singularize
    @_module = file_name

    # puts ">>> #{args.inspect}"
    # puts ">>> #{options.inspect}"

    # @verbose = args.include?("verbose:true")
    @_messages = []
    @_current_dir = File.dirname(__FILE__)
  end

  def bower_json
    # bower.json

#%s/lib\/generators\/angular_module/#{@_current_dir}/gc


    file = "#{@_current_dir}/templates/bower.json"
    begin
      out_file = file.gsub(/^.+\/templates\//, "")
      # out_file = file.gsub(/\/templates\//, "\/out\/")
      cp(file, out_file)
    rescue => e
      raise AngularModuleGeneratorError.new("Unable to bootstrap #{file}", e)
    end
  end

  def package_json
    # package.json

    file = "#{@_current_dir}/templates/package.json"
    begin
      out_file = file.gsub(/^.+\/templates\//, "")
      # out_file = file.gsub(/\/templates\//, "\/out\/")
      unless file_exists?(out_file)
        out_dir = File.dirname(out_file)
        mkdir_p(out_dir)
        cp(file, out_file)
      end

      # Object.send("remove_const", "ThorActions")
      # class ThorActions < Thor::Group
      #   include Thor::Actions
      # end
      # thor = ThorActions.new

      inject_into_file out_file, before: /\s*\"test\": \"node\s*.*/ do 
        content = <<-RUBY

    "test-#{@_module}": "node node_modules/karma/bin/karma start spec/jasmine/unit/#{@_module}/karma.conf.js",
RUBY
        content.chomp
      end

      inject_into_file out_file, before: /[\r\n]+\s*\"protractor\": \"protractor\s*.*$/ do 
        content = <<-RUBY

    "protractor-#{@_module}": "protractor spec/jasmine/e2e/#{@_module}/protractor-conf.js",
RUBY
        content.chomp
      end

    rescue => e
      raise AngularModuleGeneratorError.new("Unable to bootstrap/update #{file}", e)
    end
  
  end

  def static_pages_html_erb
    # static_pages.html.erb
    file = "app/views/layouts/static_pages.html.erb"
    begin
      #files = Dir.glob("#{@_current_dir}/templates/app/views/static_pages/**/*")

      cp_r("#{@_current_dir}/templates/app/views/static_pages", "./app/views/static_pages")

      # cnt = 0
      # files.each do |file|
      #   out_file = file.gsub(/^.+\/templates\//, "")
      #   # out_file = file.gsub(/\/templates\//, "\/out\/")
      #   out_file.gsub!(/\/module/, "\/#{@_module}")
      #   
      #   next if file_exists?(out_file)
      #   cnt += 1

      #   content = IO.read(file)
      #   content.gsub!(/{module-singular}/, @_module_singular)
      #   content.gsub!(/{module-capitalized}/, @_module_capitalized)
      #   content.gsub!(/{module}/, @_module)

      #   out_dir = File.dirname(out_file)
      #   mkdir_p(out_dir)

      #   say_status :created, "cp #{file} \\"
      #   say_status "", out_file
      #   File.open(out_file, "w"){|f| f.write(content) }
      # end


      src_file = "#{@_current_dir}/templates/app/views/layouts/static_pages.html.erb"
      out_file = file
      # out_file = "#{@_current_dir}/out/app/views/layouts/application.html.erb"
      
      out_dir = File.dirname(out_file)
      mkdir_p(out_dir)

      unless file_exists?(out_file)
        cp src_file, out_file
      end

      content = IO.read(out_file)

      if(content =~ /\"#{@_module}\"/m)
        # and ask("It looks like the #{@_module} module was already included; include again?", :red, \
        # add_to_history: false, limited_to: ["y", "n"]) == "n")
        ## and no?("It looks like the #{@_module} module was already included; include again?", color = :red) == true)
        
        say_status :skip, file, :blue

      else
        File.open(out_file, "w"){|f| 
          lines = content.split(/\n/)

          new_lines = []
          look_for_end_of_block = false
          finished = false

          lines.each do |line|

            # line="  <%= stylesheet_link_tag    \"angular\", \"phones\", \"restaurants\", \"application\", media: \"all\" %>"
            # line="  <%= stylesheet_link_tag    \"angular\", \"phones\", \"restaurants\", media: \"all\" %>"
            # line="  <%= stylesheet_link_tag    \"angular\", \"phones\", \"restaurants\" %>"
            # line="  <%= javascript_include_tag    \"angular\", \"phones\", \"restaurants\", \"application\" %>"

            # re = /<%= (stylesheet_link_tag|javascript_include_tag)\s+((\"[^\"]+\", )+(?=(\"application\", )))(.*)/
            # re = /<%= (stylesheet_link_tag|javascript_include_tag)(\s+)((\"[^\"]+\", )+(?=(\"application\")))(.*)/
            re_2 = /<%= (stylesheet_link_tag|javascript_include_tag)(\s+)((\"[^\"]+\", )+(?=([\w\d]+:\s*\"[^\"]+\",?)))(.*)/
            re_3 = /<%= (stylesheet_link_tag|javascript_include_tag)(\s+)((.*)(?=( \%>)))(.*)/

            # if(line =~ re)
            #   md = line.match(re)
            #   line="  <%= #{md[1]}#{md[2]}#{md[3]}\"#{@_module}\", #{md[6]}"

            if(line =~ re_2)
              md = line.match(re_2)
              line="  <%= #{md[1]}#{md[2]}#{md[3]}\"#{@_module}\", #{md[6]}"

            elsif(line =~ re_3)
              md = line.match(/(.*)(?=( \%>))(.*)/)
              md = line.match(re_3)
              # line="  <%= #{md[1]}#{md[2]}#{md[3]}, \"#{@_module}\", media: \"all\"#{md[6]}"
              line="  <%= #{md[1]}#{md[2]}#{md[3]}, \"#{@_module}\"#{md[6]}"

            end

            new_lines << line
          end
          
          f.write(new_lines.join("\n")) 
        }

        say_status :insert, file
      end
    rescue => e
      raise AngularModuleGeneratorError.new("Unable to update #{file}", e)
    end
  end

  def static_pages
    file = "config/routes.rb"
    controller_file = "app/controllers/static_pages_controller.rb"
    layout_file = "app/views/layouts/static_pages.html.erb"
    begin
      if(!File.exists?(controller_file))
        #generate "controller", "StaticPages index --skip-assets --skip-helper"
        src_file = "#{@_current_dir}/templates/#{controller_file}"
        cp src_file, controller_file

        src_file = "#{@_current_dir}/templates/#{layout_file}"
        cp src_file, layout_file
      end

      re_root_route_static_pages = /^\s*root 'static_pages#index'/
      re_root_route = /^\s*root.*/
      # re_index_action = /\s*def index[\r\n]+\s*end\s*\n/
      re_angular_actions = /# AngularJS actions.*\n/

      content = IO.read(controller_file)
      unless(content =~ re_angular_actions)
        raise <<-EOL

The angular_module generator requires '# AngularJS actions' to 
be declared in a public section of the StaticPagesController.

E.g., 
  def index
    @angular_app_name = "restauranteur"
  end

  # AngularJS actions
  def apples
    render action: :index
  end
EOL
      end

      content = IO.read(file)
      if(content =~ re_root_route and !(content =~ re_root_route_static_pages))
        @_messages << <<-EOF
There is already a 'root' route defined in config/routes.rb.
If you want the root route to point to an AngularJS controller
and it isn't already, you will need to manually change it.

E.g., root 'static_pages#index'
EOF
      else
        route "root 'static_pages#index'"
      end

      route "get \"#{@_module}\" => 'static_pages##{@_module}'"

      inject_into_file controller_file, after: re_angular_actions do 
        content = <<-RUBY
  def #{@_module}
    render action: :index
  end
RUBY
      end
      
    rescue => e
      #raise AngularModuleGeneratorError.new("Unable to bootstrap static_pages (#{file}, #{controller_file})", e)
      raise AngularModuleGeneratorError.new("Unable to bootstrap static_pages (#{file}, #{controller_file})", e)
    end
  end

  def application_rb
    # application.rb
    file = "config/application.rb"
    
    begin
      re = re_after_append_asset_paths = /# DO NOT REMOVE: config\.assets\.paths\.unshift(.*)[\r\n]+/
      re = re_config_assets_precompile = /# DO NOT REMOVE: config.assets.precompile(.*)[\r\n]+/

      content = IO.read(file)
      unless(content =~ re_after_append_asset_paths or content =~ re_config_assets_precompile)
        msg = <<-EOL
  missing tokens in #{file}; fix first before adding another AngularJS module

  e.g., 

      initializer :after_append_asset_paths, 
                  :group => :all, 
                  :after => :append_assets_path do

  >>>   # DO NOT REMOVE: config.assets.paths.unshift
        config.assets.paths.unshift Rails.root.join("vendor", "assets", "angular").to_s
      end

  >>> # DO NOT REMOVE: config.assets.precompile
      config.assets.precompile += ['angular.js', 'angular.css']
  EOL
        raise AngularModuleGeneratorError.new(msg)
      end

      out_file = file
      # out_file = "#{@_current_dir}/out/config/application.rb"

      # Object.send("remove_const", "ThorActions")
      # class ThorActions < Thor::Group
      #   include Thor::Actions
      # end
      # thor = ThorActions.new

      inject_into_file out_file, after: re_after_append_asset_paths do 
    content = <<-RUBY
      config.assets.paths.unshift Rails.root.join("app", "assets", "#{@_module}").to_s
RUBY
      end

      inject_into_file out_file, after: re_config_assets_precompile do 
    content = <<-RUBY
    config.assets.precompile += ['#{@_module}.js', '#{@_module}.css']
RUBY
      end
    rescue => e
      raise AngularModuleGeneratorError.new("Unable to update #{file}", e)
    end
  end

  def module_app_assets
    begin
      files = Dir.glob("#{@_current_dir}/templates/app/assets/module/**/*.js")
      files.concat(Dir.glob("#{@_current_dir}/templates/app/assets/module/**/*.css"))
      cnt = 0

      files.each do |file|
        out_file = file.gsub(/^.+\/templates\//, "")
        # out_file = file.gsub(/\/templates\//, "\/out\/")
        out_file.gsub!(/\/module/, "\/#{@_module}")
        
        next if file_exists?(out_file)
        cnt += 1

        content = IO.read(file)
        content.gsub!(/{module-singular}/, @_module_singular)
        content.gsub!(/{module-capitalized}/, @_module_capitalized)
        content.gsub!(/{module}/, @_module)

        out_dir = File.dirname(out_file)
        mkdir_p(out_dir)

        say_status :created, "cp #{file} \\"
        say_status "", out_file
        File.open(out_file, "w"){|f| f.write(content) }
      end

      say_status :generate, "app/assets/#{@_module} (#{cnt}/#{files.length})"
    rescue => e
      raise AngularModuleGeneratorError.new("Unable to generate public resources", e)
    end
  end

  def module_specs
    begin
      files = Dir.glob("#{@_current_dir}/templates/spec/jasmine/**/*.js")
      cnt = 0

      files.each do |file|
        out_file = file.gsub(/^.+\/templates\//, "")
        # out_file = file.gsub(/\/templates\//, "\/out\/")
        out_file.gsub!(/\/module/, "\/#{@_module}")
        
        next if file_exists?(out_file)
        cnt += 1

        content = IO.read(file)
        content.gsub!(/{module-singular}/, @_module_singular)
        content.gsub!(/{module-capitalized}/, @_module_capitalized)
        content.gsub!(/{module}/, @_module)
        content.gsub!(/{port}/, '3640')

        out_dir = File.dirname(out_file)
        mkdir_p(out_dir)

        say_status :created, "cp #{file} \\"
        say_status "", out_file
        File.open(out_file, "w"){|f| f.write(content) }
      end


      files = Dir.glob("spec/jasmine/unit/**/karma.conf.js")
      re_karma_test_pattern = /^\s*'spec\/jasmine\/unit\/module\/\*pec\.js'/
      
      files.each do |file|
        inject_into_file file, before: re_karma_test_pattern do 
          content = <<-RUBY

      'app/assets/#{@_module}/**/*.js',
      'spec/jasmine/unit/#{@_module}/*pec.js',
RUBY
        end
      end

      say_status :generate, "spec/jasmine/#{@_module} (#{cnt}/#{files.length})"
    rescue => e
      raise AngularModuleGeneratorError.new("Unable to generate spec resources", e)
    end
  end

  def module_public_resources
    begin
      files = Dir.glob("#{@_current_dir}/templates/public/module/module/**/*")
      files.concat Dir.glob("#{@_current_dir}/templates/public/module/partials/**/*")
      cnt = 0

      files.each do |file|
        #out_file = file.gsub(/\/templates\//, "\/out\/")
        out_file = file.gsub(/^.+\/templates\//, "")
        out_file.gsub!(/module-/, "#{@_module_singular}-")
        out_file.gsub!(/module/, "#{@_module}")

        next if file_exists?(out_file)
        cnt += 1

        content = IO.read(file)
        content.gsub!(/{module-singular}/, @_module_singular)
        content.gsub!(/{module-capitalized}/, @_module_capitalized)
        content.gsub!(/{module}/, @_module)

        out_dir = File.dirname(out_file)
        mkdir_p(out_dir)

        say_status :created, out_file
        File.open(out_file, "w"){|f| f.write(content) }
      end

      img_files = Dir.glob("#{@_current_dir}/templates/public/module/img/**/*")
      img_files.each do |file|
        next if File.ftype(file) == "directory"

        out_file = file.gsub(/^.+\/templates\//, "")
        out_file.gsub!(/module-/, "#{@_module_singular}-")
        out_file.gsub!(/module/, "#{@_module}")
        next if file_exists?(out_file)
        cnt += 1

        out_dir = File.dirname(out_file)
        unless file_exists?(out_dir)
          mkdir_p(out_dir)
        end
        
        cp file, out_file
      end
    
      say_status :generate, "public/#{@_module} (#{cnt}/#{files.length + img_files.length})"
    rescue => e
      raise AngularModuleGeneratorError.new("Unable to generate public resources", e)
    end
  end

  def show_messages
    if(@_messages.length > 0)
    say <<-EOL
======================================================
Post task items:

- #{@_messages.join("\n\n- ")}
======================================================
EOL
    end
      
  end

  private

  def mkdir_p(out_dir)
    return if file_exists?(out_dir)
  
    FileUtils.mkdir_p(out_dir)
    say_status :created, "mkdir -p #{out_dir}"
  end

  def cp(file, out_file)
    return if file_exists?(out_file)

    FileUtils.cp file, out_file
    say_status :copied, "cp #{file} #{out_file}"
  end
  
  def cp_r(file, out_file)
    return if file_exists?(out_file)

    FileUtils.cp_r file, out_file
    say_status :copied, "cp -r #{file} #{out_file}"
  end

  def file_exists?(out_file, prompt_when_conflict=false)
    file_existence = File.exists?(out_file)
    if file_existence
      if(prompt_when_conflict and File.ftype(out_file) != "directory")
        file_existence = (file_collision(out_file) == false)
      else
        say_status :exist, out_file, :blue
      end
    end

    return file_existence
  end


  def disabled_application_js
    # application.js

    file = "app/assets/javascripts/application.js"
    begin
      unless file_exists?(file)
        src_file = "#{@_current_dir}/templates/app/assets/javascripts/application.js"
        out_dir = File.dirname(file)
        mkdir_p(out_dir)
        cp(src_file, out_dir)
      end

      out_file = file

      re = /\/\/= require app/m
      content = IO.read(out_file)
      unless(content =~ re)
        open(out_file, 'a') do |f|
          f << "\n//= require app"
        end
        say_status :insert, out_file
      end
    rescue => e
      raise AngularModuleGeneratorError.new("Unable to bootstrap/update #{file}", e)
    end

  end

  def disabled_app_js
    # app.js

    file = "app/assets/javascripts/app.js"
    begin
      unless file_exists?(file)
        src_file = "#{@_current_dir}/templates/app/assets/javascripts/app.js"
        out_dir = File.dirname(file)
        mkdir_p(out_dir)
        cp(src_file, out_dir)
      end

      out_file = file

      # Object.send("remove_const", "ThorActions")
      # class ThorActions < Thor::Group
      #   include Thor::Actions
      # end
      # thor = ThorActions.new

      inject_into_file out_file, before: /[\r\n]var\s+[^\s]+\s+=\s+angular\.module/ do 
    content = <<-RUBY
myAppModules << '#{@_module}App'
RUBY
      end
    rescue => e
      raise AngularModuleGeneratorError.new("Unable to bootstrap/update #{file}", e)
    end
  end

  def disabled_application_js
    # application.js

    file = "app/assets/javascripts/application.js"
    begin
      unless file_exists?(file)
        raise "Unable to find file: ${file}; create the file and try again\ne.g., 'touch ${file}'"
      end

      out_file = file

      # re = /(.*\/\/)=\s*(require\s+(jquery|jquery_ujs|turbolinks)\s*.*)/
      # gsub_file out_file, re, '\1 \2'

      %w{jquery_ujs jquery turbolinks}.each do |term|
        re = Regexp.new('(.*\/\/)=\s*(require\s+' + term + '\s*.*)')
        gsub_file out_file, re, '\1 \2'
      end
    rescue => e
      raise AngularModuleGeneratorError.new("Unable to bootstrap/update #{file}", e)
    end

  end

  
end
