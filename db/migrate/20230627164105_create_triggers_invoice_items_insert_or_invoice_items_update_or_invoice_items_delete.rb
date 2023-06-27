# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggersInvoiceItemsInsertOrInvoiceItemsUpdateOrInvoiceItemsDelete < ActiveRecord::Migration[7.0]
  def up
    create_trigger("invoice_items_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("invoice_items").
        after(:insert) do
      <<-SQL_ACTIONS

			DECLARE 
				output TEXT;
			BEGIN
				output := 'operation=insert;table=invoice_items;id=' || NEW.invoice_id || ';new_quantity=' || NEW.quantity || ';new_amount_per_unit=' || NEW.amount_per_unit;
				PERFORM pg_notify('invoice_item_channel', output);
			END;
      SQL_ACTIONS
    end

    create_trigger("invoice_items_after_update_of_quantity_amount_per_unit_row_tr", :generated => true, :compatibility => 1).
        on("invoice_items").
        after(:update).
        of(:quantity, :amount_per_unit) do
      <<-SQL_ACTIONS

			DECLARE 
				output TEXT;
			BEGIN
				output := 'operation=update;table=invoice_items;id=' || NEW.invoice_id || ';new_quantity=' || NEW.quantity || ';new_amount_per_unit=' || NEW.amount_per_unit || ';old_quantity=' || OLD.quantity || ';old_amount_per_unit=' || OLD.amount_per_unit;
				PERFORM pg_notify('invoice_item_channel', output);
			END;
      SQL_ACTIONS
    end

    create_trigger("invoice_items_after_delete_row_tr", :generated => true, :compatibility => 1).
        on("invoice_items").
        after(:delete) do
      <<-SQL_ACTIONS

			DECLARE 
				output TEXT;
			BEGIN
				output := 'operation=update;table=invoice_items;id=' || NEW.invoice_id || ';old_quantity=' || OLD.quantity || ';old_amount_per_unit=' || OLD.amount_per_unit;
				PERFORM pg_notify('invoice_item_channel', output);
			END;
      SQL_ACTIONS
    end
  end

  def down
    drop_trigger("invoice_items_after_insert_row_tr", "invoice_items", :generated => true)

    drop_trigger("invoice_items_after_update_of_quantity_amount_per_unit_row_tr", "invoice_items", :generated => true)

    drop_trigger("invoice_items_after_delete_row_tr", "invoice_items", :generated => true)
  end
end
