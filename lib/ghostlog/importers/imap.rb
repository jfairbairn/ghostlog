require 'mail'
require 'nokogiri'
require 'digest/sha1'

module Ghostlog
  module Importer
    class IMAP
      attr_reader :config
      
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
        mails = Mail.find(mailbox: config[:folder], what: :last, count: 10) do |mail|
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

          FileUtils.mkdir_p 'mailcontent'

          i=0

          id2filename = {}

          parts.each do |part|
            if part.content_type !~ /^text\// && part.content_type =~ /\/(\w+)(; )?/
              ext = $1
              cid = part.content_id.gsub(/^<(.*)>$/, '\1')
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
            projects: config[:projects]
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
                    link['src'] = v
                  end
                end
                header = <<-EOF
                <dl class="mail">
                  <dt>From:</dt>
                  <dd>#{(mail.from||[]).join(', ')}</dd>

                  <dt>Date:</dt>
                  <dd>#{mail.date.rfc822}</dd>

                  <dt>To:</dt>
                  <dd>#{(mail.to||[]).join(', ')}</dd>

                  <dt>Cc:</dt>
                  <dd>#{(mail.cc||[]).join(', ')}</dd>

                  <dt>Subject:</dt>
                  <dd>#{mail.subject}</dd>

                </dl>
                EOF
                html.css('body').each do |b|
                  b.first_element_child.add_previous_sibling(header)
                end

                body = html.to_html
                doc[:content] = body
                @index.put(doc)
              end
            end
          end
        end
      end
    end
  end
end
