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

def setup
  header = "<!DOCTYPE html>
            <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
            <html lang=\"en\">
            <head>
            <meta http-equiv=\"content-type\" content=\"application/xhtml+xml; charset=UTF-8\" >
            <title>Worm</title>
            </head>
            <body>"
  output_filename = 'worm9.html'
  FileUtils.touch(output_filename)
  output_file = File.open("./#{output_filename}", "w+")
  output_file << header
  return output_file
end
def main
  puts "\n\nSCRAPER STARTING\n\n"
  output_file = setup
  toc = "https://parahumans.wordpress.com/table-of-contents/"
  puts "starting at: #{toc}"
  agent = Mechanize.new
  toc_page = agent.get(toc)
  toc_page = remove_nodes(toc_page, "#jp-post-flair")
  links = toc_page.css("#content div.entry-content a")
  hrefs = []
  links.each do |link|
    hrefs << link['href']
  end
  hrefs.uniq!
  puts hrefs

  hrefs.first(5).each do |url|
    delay(3.0, 2.0)
    page = agent.get(url)
    title = page.at_css('.entry-title').text
    body = page.at_css('.entry-content')
    body_text = strip_nav(body.css('p'))
    puts "Current title: #{title}"

    output_file << "<h1 style=\"page-break-before:always;\">#{title}</h1>"
    output_file << "#{body_text}"

  end

  finish(output_file)
end

def finish(output_file)
  footer = "</body>
            </html>"
  output_file << footer
end

def delay(base, extra)
  prng = Random.new
  wait_time = base + prng.rand(extra)
  puts "sleeping"
  sleep(wait_time)
  puts "waking"
end

def strip_nav(nodes)
  nodes.search("a").each do |a|
    if a['title'] && (a['title'].include?("Next") ||
                      a['title'].include?("Last"))
      a.remove
    elsif a.text.include?("Next") || a.text.include?("Last")
      a.remove
    end
  end
  return nodes
end


def remove_nodes(body, matcher)
  body.search(matcher).each do |match|
    match.remove
  end
  return body
end

main
