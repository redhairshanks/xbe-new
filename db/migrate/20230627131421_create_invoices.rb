class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices, id: :uuid do |t|
      t.string :invoice_no
      t.integer :total_amount
      t.timestamps
    end
  end
end
