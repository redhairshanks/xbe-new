class InvoiceItemListener
	include Sidekiq::Worker
	sidekiq_options retry: false

	def perform
		ActiveRecord::Base.connection_pool.with_connection do |connection|
		  	conn = connection.instance_variable_get(:@connection)
		  	begin
		  	    conn.async_exec "LISTEN invoice_item_channel"
		  	    loop do
		  	      	conn.wait_for_notify do |channel, pid, payload|
		  	        	process_notification(channel, payload)
		  	        end
		  	    end
		  	ensure
		  		conn.async_exec "UNLISTEN *"
		  	end
	  	end
	end

	def process_notification(channel, payload)
		puts "Received NOTIFY on channel #{channel} with payload: #{payload}"
		op_map = payload.split(";").map{|x| x.split("=")}.map{|x| [x[0], x[1]]}.to_h
		DatabaseNotification.create(event: channel, payload: op_map)
		get_invoice_total_sum(op_map)
	end

	private 

	def get_invoice_total_sum(params)
		invoice = Invoice.find_by(params[:id])
		if invoice.blank?
			raise XbeException::GeneratedException.new "Invoice not found with id=#{params[:id]}"	
		end
		invoice_items = invoice.invoice_items
		total_amount  = 0
		invoice_items.map{|x| total_amount += (x[:quantity] * x[:amount_per_unit])}
		invoice.total_amount = total_amount
		invoice.save
		if invoice.present? && invoice.errors.present?
			raise XbeException::GeneratedException.new "Unable to update invoice on invoice_item operation=#{params[:operation]} errors=#{invoice.errors.messages}"
		end
	end
end