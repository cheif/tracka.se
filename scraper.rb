# encoding=utf-8
require 'xml'
require 'mechanize'
require 'open-uri'

class Scraper
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Mac Safari'

    def self.Posten(kolliid)
        posten_url = "http://www.posten.se/sv/Kundservice/Sidor/Sok-brev-paket.aspx"
        search_page = @agent.get(posten_url)
        search_form = search_page.form('aspnetForm')
        search_form['ctl00$m$g_830dbf6e_6765_4420_94b5_78a952f9b7bd$ctl00$txtShipmentId'] = kolliid
        result = @agent.submit(search_form, search_form.buttons.first)
        events = result.search("table.nttEventsTable/tr")[1..-1].map do |event|
            date, location, message = event.search("td").map{|e| e.content.strip}
            {
                :date => date,
                :location => location,
                :message => message
            }
        end
        return {
            :id => kolliid,
            :sender => result.search("span#ctl00_m_g_830dbf6e_6765_4420_94b5_78a952f9b7bd_ctl00_ctl20_lblSenderValue").first.content,
            :service => 'Posten',
            :events => events.sort_by{|eln| eln[:date]}.reverse!
        }

        #TODO Error handling!

        posten_url = "http://server.logistik.posten.se/servlet/PacTrack?lang=SE&kolliid="
        raw = open(posten_url + kolliid).read
        parser = XML::Parser.string(raw)
        doc = parser.parse
        if doc.root.find_first('./body/parcel/internalstatus') && doc.root.find_first('./body/parcel/internalstatus').content == "1"
            events = doc.root.find('./body/parcel/event').map do |event|
                date = event.find_first('date').content + " "
                date += event.find_first('time').content.insert(2,':')
                {
                    :date => date,
                    :location => event.find_first('location').content,
                    :message => event.find_first('description').content
                }
            end
            return {
                :id => kolliid,
                :sender => doc.root.find_first('./body/parcel/customername').content,
                :service => 'Posten',
                :events => events.sort_by{|eln| eln[:date]}.reverse!
            }
        else
            return {
                :error => 'Not found'
            }
        end
    end
end
