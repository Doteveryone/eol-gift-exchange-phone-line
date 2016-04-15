class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.string :sender
      t.string :sender_audio
      t.string :recipient
      t.string :recipient_audio
      t.string :place
      t.string :place_audio
      t.string :story_audio
      t.string :call_sid
      t.boolean :sent
    end
  end
end
