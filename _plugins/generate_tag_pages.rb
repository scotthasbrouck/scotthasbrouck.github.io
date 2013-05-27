module Jekyll

	class TagPages < Generator
		def generate(site)
			site.pages.dup.each do |page|
			  paginate(site, page) if TagPager.pagination_enabled?(site.config, page)
			end
		end

		def paginate(site, page)

			# sort tags by descending date of publish
			tag_posts = site.tags[page.data['tag']].sort_by { |p| -p.date.to_f }

			# calculate total number of pages
			pages = TagPager.calculate_pages(tag_posts, site.config['paginate'].to_i)

			# iterate over the total number of pages and create a physical page for each
			(1..pages).each do |num_page|

				# the TagPager handles the paging and tag data
				pager = TagPager.new(site.config, num_page, tag_posts, page.data['tag'], pages)

				# the first page is the index, so no page needs to be created. However, the subsequent pages need to be generated
				if num_page > 1
					newpage = TagSubPage.new(site, site.source, page.data['tag'], page.data['tag_layout'])
					newpage.pager = pager
					newpage.dir = File.join("/#{page.data['tag']}/#{num_page}")
					site.pages << newpage
				else
					page.pager = pager
				end
			end
		end
	end

	# The TagSubPage class creates a single tag page for the specified tag.
	# This class exists to specify the layout to use for pages after the first index page
	class TagSubPage < Page
		def initialize(site, base, tag, layout)
			@site = site
			@base = base
			@dir  = tag
			@name = 'index.html'

			self.process(@name)
			self.read_yaml(File.join(base, '_layouts'), layout || 'tag_index.html')

			title_prefix             = site.config['tag_title_prefix'] || 'all posts on '
			self.data['title']       = "#{title_prefix}#{tag}"
		end
	end


	class TagPager < Pager
		attr_reader :tag
		def self.pagination_enabled?(config, page)
			page.name == 'index.html' && page.data.key?('tag') && !config['paginate'].nil?
		end

		# same as the base class, but includes the tag value
		def initialize(config, page, all_posts, tag, num_pages = nil)
			@tag = tag
			title_prefix = config['cateogry_title_prefix'] || 'all posts on '
			@title = "#{title_prefix}#{tag}"
			super config, page, all_posts, num_pages
		end

		# use the original to_liquid method, but add in tag and title info
		alias_method :original_to_liquid, :to_liquid
		def to_liquid
			x = original_to_liquid
			x['tag'] = @tag
			x['title'] = @title
			x
		end
	end
end