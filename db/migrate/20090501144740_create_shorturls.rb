class CreateShorturls < ActiveRecord::Migration
  def self.up
    create_table :shorturls do |t|
      t.string :target_url
      t.string :keyword

      t.timestamps
    end
  end

  def self.down
    drop_table :shorturls
  end
end
