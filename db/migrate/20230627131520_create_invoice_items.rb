class CreateInvoiceItems < ActiveRecord::Migration[7.0]
  def change
    create_table :invoice_items, id: :uuid do |t|
      t.belongs_to :invoice, foreign_key: true, type: :uuid, null: false
      t.integer :quantity
      t.integer :amount_per_unit
      t.timestamps
    end
  end
end
