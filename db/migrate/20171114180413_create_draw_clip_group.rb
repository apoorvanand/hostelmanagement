class CreateDrawClipGroup < ActiveRecord::Migration[5.0]
  def change
    create_view :draw_clip_groups
  end
end
