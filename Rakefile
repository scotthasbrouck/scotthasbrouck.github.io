require 'rubygems'
require 'optparse'
require 'yaml'

task :publish do
	system "s3cmd sync _site/ s3://spectra.io"
end

task :np do
  OptionParser.new.parse!
  ARGV.shift
  title = ARGV.join(' ')

  path = "_posts/#{Time.now.strftime('%Y')}/#{Date.today}-#{title.downcase.gsub(/[^[:alnum:]]+/, '-')}.markdown"
  
  if File.exist?(path)
  	puts "[WARN] File exists - skipping create"
  else
    File.open(path, "w") do |file|
      file.puts YAML.dump({'layout' => 'post',
      						'published' => false,
      						'comments' => true,
      						'title' => title,
      						'date' => "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}",
      						'tags' => [],
      						'category' => '' })
      file.puts "---"
    end
  end
  `subl #{path}`

  exit 1
end