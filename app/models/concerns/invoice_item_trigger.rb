module InvoiceItemTrigger 
	extend ActiveSupport::Concern

	included do 
		trigger.after(:insert) do 
			"
			DECLARE 
				output TEXT;
			BEGIN
				output := 'operation=insert;
						   table=invoice_items;
						   id=' || NEW.invoice_id || ';
						   new_quantity=' || NEW.quantity || ';
						   new_amount_per_unit=' || NEW.amount_per_unit;
				PERFORM pg_notify('invoice_item_channel', output);
			END
			"
		end


		trigger.after(:update).of(:quantity, :amount_per_unit) do 
			"
			DECLARE 
				output TEXT;
			BEGIN
				output := 'operation=update;
						   table=invoice_items;
						   id=' || NEW.invoice_id || ';
						   new_quantity=' || NEW.quantity || ';
						   new_amount_per_unit=' || NEW.amount_per_unit || ';
						   old_quantity=' || OLD.quantity || ';
						   old_amount_per_unit=' || OLD.amount_per_unit;
				PERFORM pg_notify('invoice_item_channel', output);
			END
			"
		end

		trigger.after(:delete) do 
			"
			DECLARE 
				output TEXT;
			BEGIN
				output := 'operation=update;
				           table=invoice_items;
				           id=' || NEW.invoice_id || ';
				           old_quantity=' || OLD.quantity || ';
				           old_amount_per_unit=' || OLD.amount_per_unit;
				PERFORM pg_notify('invoice_item_channel', output);
			END
			"
		end
	end
end