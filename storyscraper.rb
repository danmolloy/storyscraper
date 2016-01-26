require 'rubygems'
require 'mechanize'
require 'fileutils'
###Must declare UTF encoding - kindlegen natively using windows 1252###
###after 4.2 Next nav links stop having title attr. Need to match on text###
#Target inputs:
#		-worm + other wildbow
#		-fanfiction.net
#		-archiveofourown
#		-fimfiction.net
#		-talesofmu
#		-spacebattles etc. (low priority)
#
def main
  puts "\n\nSCRAPER STARTING\n\n"
  output_file = 'worm5.html'
  FileUtils.touch(output_file)
  output_file = File.open("./#{output_file}", "w+")
  start = 'https://parahumans.wordpress.com/category/stories-arcs-1-10/arc-3-agitation/3-x-interlude/'
  puts "starting at: #{start}"
  agent = Mechanize.new
  page = agent.get(start)
  done = false

  until done == true do
    title = page.at_css('.entry-title').text
    body = page.at_css('.entry-content')
    #nav_next = page.at_css("a[title='Next Chapter']")
    nav_next = find_nav(page)
    nav_next.remove
    remove_nodes(body, nav_next)
    remove_nodes(body, "a[title='Next Chapter']")
    remove_nodes(body, "a[title='Last Chapter']")
    remove_nodes(body, "#jp-post-flair")

    #body = body.text
    puts "Current title: #{title}"

    output_file << "#{title}\n\n"
    output_file << "#{body}\n\n\n\n"

    prng = Random.new
    wait_time = 5.0 + prng.rand(3.0)
    puts "sleeping"
    sleep(wait_time)
    puts "waking"

    if nav_next
      page = agent.get(nav_next['href'])
    else
      done = true
      puts "FINISHED"
    end
  end
end

def find_nav(page)
  page_links = page.css('a')
  page_links.each do |link|
    if link.text == 'Next Chapter'
      return link
    end
  end
  return nil
end

def remove_nodes(body, matcher)
  body.search(matcher).each do |match|
    match.remove
  end
  return body
end

main
