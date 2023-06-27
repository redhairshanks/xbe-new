# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_06_27_164105) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "database_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "event"
    t.json "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoice_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "invoice_id", null: false
    t.integer "quantity"
    t.integer "amount_per_unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
  end

  create_table "invoices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "invoice_no"
    t.integer "total_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "invoice_items", "invoices"
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
