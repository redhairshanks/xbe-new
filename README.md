# README

## Changes that needed addressing
- Code Quality - Indentation is now improved and uniform
- Model Clarity - Have used concern to separate out trigger code from model files
- Pull Request - See PR [pravin/sql_triggers](https://github.com/redhairshanks/xbe-new/pull/1)
- Calculation issues, Notification channel, Functional Responsibilities, Sidekiq Usage
  - Have made a design decision here.
  - Triggers now are only used for notification and not for changing database entries
  - Processing of the trigger is done via database listener
  - Currently have created InvoiceItemListener (as sidekiq worker) which listens on **invoice_item_channel**
  - pg_notify sends in the information of the invoice whose items have been created/updated/deleted and for every such call - invoice total_amount is calculated again. 
  - This was to avoid missed notifications. Now every notification calculates the total_amount in invoice independently
  - Removed the redundant rake task


## To run the code
- Clone the repository
- Change directory to xbe `cd xbe` 
- Install dependencies `bundle install`
- You need a postgres server running with username as 'root' and password as 'root' and database `xbe_new` with root getting all privileges
- Create database `rake db:create`
- Install db changes `rake db:migrate`
- In new terminal run to start sidekiq `bundle exec sidekiq -e development -C config/sidekiq.yml`

## Gems used
1. gem 'hairtrigger', '~> 1.0' // For creating triggers within rails env
2. gem 'sidekiq', '~> 7.1', '>= 7.1.2' # For background processes
3. gem "rspec-rails" # For testing.

## Models
1. Invoices - id (uuid), invoice_no(string), total_amount(int), timestamps
2. Invoice_items - id(uuid), invoice_id(foreign_key), quantity(int), amount_per_unit(int), timestamps
   - Triggers on create, update, delete
   - Every trigger contains pg_notify which sends messages on `invoice_item_channel` channel
3. Database_notifications - event(string), payload(json)
