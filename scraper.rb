# encoding=utf-8
require 'xml'
require 'mechanize'
require 'json'

class Scraper
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Mac Safari'

    def self.All(kolliid)
        #Test all scrapers
        methods = self.methods(false)[1..-1]
        result = nil
        #TODO Run in parallel and exit on valid result instead
        methods.each{|method|
            result = send(method, kolliid)
            if not result[:error]
                break
            end
        }
        return result
    end

    def self.Posten(kolliid)
        #Scrape posten.se for transaction info
        posten_url = "http://www.posten.se/sv/Kundservice/Sidor/Sok-brev-paket.aspx"
        search_page = @agent.get(posten_url)
        #Get form from tracking page
        search_form = search_page.form('aspnetForm')
        #post form with kolliid
        search_form['ctl00$m$g_830dbf6e_6765_4420_94b5_78a952f9b7bd$ctl00$txtShipmentId'] = kolliid
        result = @agent.submit(search_form, search_form.buttons.first)

        #Search table with transactioninfo
        eventsMatch = result.search("table.nttEventsTable/tr")
        if not eventsMatch.empty?
            #Map events onto ruby object
            events = eventsMatch[1..-1].map do |event|
                date, location, message = event.search("td").map{|e| e.content.strip}
                {
                    :date => date,
                    :location => location,
                    :message => message
                }
            end
            #Add additional details and sort events
            return {
                :id => kolliid,
                :sender => result.search("span#ctl00_m_g_830dbf6e_6765_4420_94b5_78a952f9b7bd_ctl00_ctl20_lblSenderValue").first.content,
                :service => 'Posten',
                :events => events.sort_by{|eln| eln[:date]}.reverse!
            }
        else
            return {
                :error => 'Not found'
            }
        end
    end

    def self.FedEx(kolliid)
        #Scrape fedex.com for transaction info
        fedex_url = "http://www.fedex.com/Tracking?tracknumbers=#{kolliid}&cntry_code=se&clienttype=ivother&"
        result = @agent.get(fedex_url)
        #All data we need is stored in the javascript variable detailInfoObject,
        #use a regex to extract the JSON string.
        jsonMatch = result.content.match(/detailInfoObject.*?({.*})/)
        if jsonMatch
            json = jsonMatch[1]
            object = JSON.parse(json)
            #map events onto ruby object
            events = object['scans'].map do |event|
                {
                    :date => event['scanDate'],
                    :location => event['scanLocation'],
                    :message => event['scanComments']
                }
            end
            #Add additional details and sort events
            #TODO change sender field, test with better fedex no.
            return {
                :id => kolliid,
                :sender => object['origLocation'],
                :service => 'FedEx',
                :events => events.sort_by{|eln| eln[:date]}.reverse!
            }
        else
            return {
                :error => 'Not found'
            }
        end
    end
end
