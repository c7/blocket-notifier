# Include required gems
require 'rubygems'
require 'highline/import'
require 'daemons'
require 'hpricot'
require 'open-uri'
require 'uri'

# Check if the first parameter is run or start
if(/^run|start$/.match(ARGV[0])) 
  # Exit when Ctrl-C is pressed
  trap "INT" do exit end
  
  # Regular expressions for URL, email address, query string and filter
  URL_PATTERN = /^http:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
  EMAIL_PATTERN = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/ 
  QUERY_PATTERN = /^.{3,}$/
  FILTER_PATTERN = /^a|p|c$/
  
  # Initialize default config hash
  @config = { 
    :base_url => 'http://www.blocket.se/li?ca=AREA&q=QUERY&cg=CATEGORY&th=0&f=FILTER',
    :area => '11_s',
    :filter => 'p',
    :sleep_interval => 10,
    :category => 0,
    :max_price => 10000,
    :min_price => 0,
  }

  # The strings used in the application
  @text = {
    :welcome                => "\nWelcome to the Blocket-Notifier!",
    :use_default_settings   => 'Do you want to use the default settings?',
    :base_url               => 'Base url: ',
    :url_not_valid          => 'You must provide a valid URL',
    :sleep_interval         => 'Sleep interval: ',
    :notify_email           => 'Notify email: ',
    :email_not_valid        => 'You must provide a valid email address',
    :search_query           => 'Search query: ',
    :search_query_not_valid => 'Query must be longer than 2 characters',
    :category_code          => 'Category code: ',
    :area_code              => 'Area code: ',
    :filter_code            => 'Filter code: ',
    :filter_code_not_valid  => 'Filter code must be a, p or c',
    :max_price              => 'Max price: ',
    :min_price              => 'Min price: ',
  }
  
  # Start out with an empty list of ads
  @matched_ads = []
  
  # Standard greeting
  say(@text[:welcome])
  
  unless(agree(@text[:use_default_settings])) 
    # Get the base url, validate using the URL_PATTERN
    @config[:base_url] = ask(@text[:base_url]) do |q|
      q.validate = URL_PATTERN
      q.responses[:not_valid] = @text[:url_not_valid]
      q.default = @config[:base_url]
    end
    
    # Get the sleep interval
    @config[:sleep_interval] = ask(@text[:sleep_interval], Integer) do |q| 
      q.default = @config[:sleep_interval]
      
      # Set the minimum interval to three minutes (default 10 minutes)
      q.above = 179
    end
  end
  
  # Get the email address to notify
  @config[:notify_email] = ask(@text[:notify_email]) do |q| 
    q.validate = EMAIL_PATTERN
    q.responses[:not_valid] = @text[:email_not_valid]
  end
  
  # The search query
  @config[:query] = ask(@text[:search_query]) do |q| 
    q.validate = QUERY_PATTERN
    q.responses[:not_valid] = @text[:search_query_not_valid]
  end
  
  # Category code for the product
  @config[:category] = ask(@text[:category_code]) do |q| 
    q.default = @config[:category]
  end
  
  # Geographical area
  @config[:area] = ask(@text[:area_code]) do |q| 
    q.default = @config[:area]
  end
  
  # Filtering
  @config[:filter] = ask(@text[:filter_code]) do |q| 
    q.validate = FILTER_PATTERN
    q.responses[:not_valid] = @text[:filter_code_not_valid]
    q.default = @config[:filter] 
  end
  
  # Set the max price
  @config[:max_price] = ask(@text[:max_price], Integer) do |q| 
    q.default = @config[:max_price] 
  end
  
  # Set the min price
  @config[:min_price] = ask(@text[:min_price], Integer) do |q| 
    q.default = @config[:min_price]
  end
end

Daemons.run_proc('blocket-notifier.rb') do
  
  # Escape the query
  @config[:query] = URI.escape(@config[:query])
  
  # Start with the base url
  search_url = @config[:base_url]
  
  # Substitute the placeholders in the URL
  [:area, :query, :category, :filter].each do |f|
    search_url.sub!(f.to_s.upcase, @config[f])
  end
    
  # This is where the magic will happen
  loop do
    # Get the search results
    # doc = open(search_url) { |f| Hpricot(f) }
    
    sleep(@config[:sleep_interval])
  end
end
