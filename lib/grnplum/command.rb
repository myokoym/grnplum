require "thor"
require "fileutils"
require "grnplum/generator"
require "grnplum/version"

module Grnplum
  class Command < Thor
    register(Generator::C, "new", "new NAME", "Generate new plugin scaffold")

    desc "global [INSTALL_PATH]", "Set or show the install path as Groonga installed path"
    def global(install_path=nil)
      unless install_path
        puts(install_dir)
        exit(true)
      end
      unless File.directory?(install_path)
        $stderr.puts("#{$0}: Invalid path: #{install_path}")
        exit(false)
      end
      File.write(config_path, install_path)
    end

    desc "build REPOSITORY_URL", "Build a plugin"
    def build(repository_url)
      FileUtils.mkdir_p(plugins_dir)
      Dir.chdir(plugins_dir) do
        rc = system("git", "clone", repository_url)
        basename = File.basename(repository_url, ".git")
        Dir.chdir(basename) do
          system("git", "pull") unless rc
          system("./autogen.sh && ./configure --prefix=#{install_dir} && make")
        end
      end
    end

    desc "list", "List built plugins"
    def list
      Dir.glob("#{plugins_dir}/*") do |path|
        basename = File.basename(path)
        puts(basename)
      end
    end

    desc "test NAME", "Test a plugin"
    def test(name)
      Dir.chdir(plugin_dir(name)) do
        system("test/run-test.sh")
      end
    end

    desc "install NAME", "Install a plugin"
    def install(name)
      Dir.chdir(plugin_dir(name)) do
        system("make", "install")
      end
    end

    desc "version", "Show version"
    def version
      puts(VERSION)
    end

    private
    def base_dir
      File.expand_path("~/.grnplum")
    end

    def config_name
      ".groonga-installed-path"
    end

    def config_path
      File.join(base_dir, config_name)
    end

    def install_dir
      unless File.file?(config_path)
        $stderr.puts("#{$0}: Please set INSTALL_DIR.")
        $stderr.puts("Usage: #{$0} global INSTALL_DIR")
        $stderr.puts(" e.g.: #{$0} global /tmp/local")
        exit(false)
      end
      File.read(config_path)
    end

    def plugins_dir
      File.join(base_dir,
                "install_directories",
                install_dir.gsub("/", "_"),
                "plugins")
    end

    def plugin_dir(name)
      File.join(plugins_dir, name)
    end
  end
end
