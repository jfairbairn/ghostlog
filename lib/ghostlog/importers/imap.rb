require 'mail'
require 'nokogiri'
require 'digest/sha1'

module Ghostlog
  module Importer
    class IMAP
      
      attr_reader :config
      
      MSGID = /^<(.*)>$/
      
      def initialize(config, index, filestore)
        @config = config
        @index = index
        @filestore = filestore
      end
      
      def import
        config = config()
        Mail.defaults do
          retriever_method :imap, {
            :address => config[:server],
            :port => config[:port] || 993,
            :user_name => config[:username],
            :password => config[:password],
            :enable_ssl => true
          }
        end
        mails = Mail.find(mailbox: config[:folder], what: :last, count: 1000) do |mail|
          parts = []
          todo = [mail]

          while msg = todo.pop
            if msg.is_a?(Mail::PartsList) || msg.multipart?
              todo.unshift(*msg.parts)
            else
              parts << msg
            end
          end

          # Save non-text content

          i=0

          id2filename = {}

          parts.each do |part|
            if part.content_type !~ /^text\// && part.content_type =~ /\/(\w+)(; )?/
              ext = $1
              cid = part.content_id.gsub(/^<(.*)>$/, '\1') if part.content_id
              cid = nil if cid == ''
              content = part.body.decoded
              filename = Digest::SHA1.new.update(content).hexdigest
              id2filename[cid] = filename
              @filestore.save(filename, part.content_type, StringIO.new(content))
            end
            i+=1
          end
          
          doc = {
            title: mail.subject,
            author: mail.from,
            date: mail.date,
            type: 'mail',
            source: 'sandpit-mail',
            tags: config[:tags]
          }

          parts.each do |part|
            if part.content_type =~ /^text\/(html|plain)(; )?/
              ext = $1 == 'plain' ? 'txt' : 'html'
              body = part.body.decoded
              # doc[:rawcontent] = body
              if $1 == 'html'
                html = Nokogiri::HTML(body)
                id2filename.each do |k,v|
                  html.xpath("//*[@src=\"cid:#{k}\"]").each do |link|
                    link['src'] = "/r/#{v}"
                  end
                end
                body = html.to_html
                doc[:content] = body
                msgid = mail.message_id
                msgid.gsub!(MSGID, '\1') if msgid
                @index.put(doc, msgid)
              end
            end
          end
        end
      end
    end
    
    register :imap, IMAP
  end
end
