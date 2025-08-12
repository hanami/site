# frozen_string_literal: true

namespace :content do
  desc "Copy content files (images, etc.) to build directory"
  task :copy_files do
    require "fileutils"

    # Mimic the same file extensions and path mapping logic from ContentFileMiddleware
    allowed_extensions = %w[.png .jpg .jpeg .gif .svg]

    puts "Copying content files to build directory..."

    # Find all allowed file types in content/
    Dir.glob("content/**/*").each do |file|
      next unless File.file?(file)
      next unless allowed_extensions.include?(File.extname(file).downcase)

      # Extract the relative path from content/
      rel_path = file.sub("content/", "")

      # Handle guides: content/guides/org/version/path -> build/guides/org/version/path
      if rel_path.match?(%r{^guides/([^/]+)/([^/]+)/(.+)$})
        match = rel_path.match(%r{^guides/([^/]+)/([^/]+)/(.+)$})
        org = match[1]
        version = match[2]
        path = match[3]
        dest_file = "build/guides/#{org}/#{version}/#{path}"

      # Handle docs: content/docs/org/slug/version/path -> build/docs/slug/version/path
      elsif rel_path.match?(%r{^docs/([^/]+)/([^/]+)/([^/]+)/(.+)$})
        match = rel_path.match(%r{^docs/([^/]+)/([^/]+)/([^/]+)/(.+)$})
        org = match[1]
        slug = match[2]
        version = match[3]
        path = match[4]
        dest_file = "build/docs/#{slug}/#{version}/#{path}"

      else
        # Skip files that don't match expected patterns
        next
      end

      # Create destination directory if it doesn't exist
      FileUtils.mkdir_p(File.dirname(dest_file))

      # Copy the file
      FileUtils.cp(file, dest_file)
      puts "  Copied: #{file} -> #{dest_file}"
    end

    puts "Content files copied successfully!"
  end
end
