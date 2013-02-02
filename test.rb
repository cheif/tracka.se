require './scraper'

require 'test/unit'

class TestScraper < Test::Unit::TestCase
    def setup
        @validPosten = '89185288421SE'
        @validFedex = '799132507376'
        @invalidAll = 'aouaoeuaa'
    end

    #Posten.se
    def test_posten_success
        result = Scraper.Posten(@validPosten)
        assert_equal(result[:service], 'Posten')
    end

    def test_posten_invalid
        result = Scraper.Posten(@invalidAll)
        assert_equal(result[:error], 'Not found')
    end

    #FedEx.com
    def test_fedex_success
        result = Scraper.FedEx(@validFedex)
        assert_equal(result[:service], 'FedEx')
    end

    def test_fedex_invalid
        result = Scraper.FedEx(@invalidAll)
        assert_equal(result[:error], 'Not found')
    end
end
