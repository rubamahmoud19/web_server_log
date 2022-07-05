# frozen_string_literal: true

require 'action_view'
include ActionView::Helpers::TextHelper # for pluralize

class WebServerLog
  attr_accessor :web_pages

  def initialize(log)
    raise 'Log file does not exist' unless File.exist?(log)

    @web_pages ||=  parse(log)
  end

  def list_pages_with_views(unique: false)
    pages_with_views = @web_pages.group_by { |web_page| web_page[:page] }
    pages_with_views.each do |key, value|
      pages_with_views[key] = unique ? value.uniq.size : value.size
    end
    pages_with_views.sort_by { |_k, v| -v }
  end

  def self.pages_visits_formatted(list)
    list.map { |page| "#{page[0]} #{ActionView::Helpers::TextHelper.pluralize(page[1], 'visit')}" }
  end

  def self.unique_pages_views_formatted(list)
    list.map { |page| "#{page[0]} #{ActionView::Helpers::TextHelper.pluralize(page[1], 'unique view')}" }
  end

  private

  # assumption: line /help_page/1 802.683.925.780 will have
  # page name = help_page/1
  # and ip = 802.683.925.780
  def parse(log)
    file = File.new(log)
    web_pages = []
    file.each_line do |line|
      web_page, ip_address = line.split
      web_pages << { page: web_page, ip: ip_address }
    end
    web_pages
  end
  # output should be: [{page: "help_page/1", ip: "802.683.925.780"}, ...]
end
