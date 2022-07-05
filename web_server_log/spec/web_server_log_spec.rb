# frozen_string_literal: true

require 'web_server_log'
# require 'helpers/web_page_helper'

RSpec.describe WebServerLog do
  let(:log) { WebServerLog.new('./logs/webserver.log') }
  let(:pages_visits) { log.list_pages_with_views }
  let(:pages_unique_views) { log.list_pages_with_views(unique: true) }
  describe '#initialize' do
    let(:fake_log) { WebServerLog.new('./logs/fakewebserver.log') }

    context "when the file doesn't exist" do
      it 'raises Log file does not exist exception' do
        expect { fake_log }.to raise_error('Log file does not exist')
      end
    end

    context 'when the file is exist' do
      it 'returns the file is exist' do
        expect(File.exist?('./logs/webserver.log')).to be_truthy
      end

      it "doesn't raise Log file does not exist exception" do
        expect { log }.not_to raise_error('Log file does not exist')
      end

      it 'returns web pages' do
        expect(log.web_pages.class).to be Array
      end
    end
  end

  describe '#list_pages_with_views' do
    context 'when list the pages visits' do
      it 'returns the number of visits' do
        expect(pages_visits.find { |page| page[0] == '/home' }[1]).to eq(78)
        expect(pages_visits.find { |page| page[0] == '/about/2' }[1]).to eq(90)
      end
      it 'returns the visits pages are ordered descinding' do
        pages_visits.each_with_index do |page, index|
          break if page == pages_visits.last

          expect(pages_visits[index][1] >= pages_visits[index + 1][1]).to be_truthy
        end
      end
    end

    context 'when list the pages unique views' do
      it 'returns the number of unique views' do
        expect(pages_unique_views.find { |page| page[0] == '/home' }[1]).to eq(23)
        expect(pages_unique_views.find { |page| page[0] == '/about/2' }[1]).to eq(22)
      end
      it 'returns the pages unique views are ordered descinding' do
        pages_unique_views.each_with_index do |page, index|
          break if page == pages_unique_views.last

          expect(pages_unique_views[index][1] >= pages_unique_views[index + 1][1]).to be_truthy
        end
      end
    end
  end

  describe '.pages_visits_formatted' do
    it 'returns the visits for /help_page/1 is present' do
      expect(WebServerLog.pages_visits_formatted(pages_visits).include?('/help_page/1 80 visits')).to be true
    end
  end

  describe '.unique_pages_views_formatted' do
    it 'return the formatted unique views for /help_page/1 is present' do
      expect(WebServerLog.unique_pages_views_formatted(pages_unique_views).include?('/help_page/1 23 unique views')).to be true
    end
  end
end
