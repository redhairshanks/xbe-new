class InvoiceItem < ApplicationRecord
	belongs_to :invoice
	
	include InvoiceItemTrigger
end