require "turbo-rails"

class Board < ActiveRecord::Base
  def dom_id
    "board_1"
  end
end

class Message < ActiveRecord::Base
  def board
    Board.new
  end

  broadcasts
  broadcasts "messages", inserts_by: :prepend, target: "board_messages"

  broadcasts_to :board
  broadcasts_to ->(message) { [ message.board, :messages ] }, inserts_by: :prepend, target: "board_messages"
  broadcasts_to :board, target: ->(message) { message.board.dom_id }

  broadcasts_refreshes
  broadcasts_refreshes "messages"
  broadcasts_refreshes_to :board
  broadcasts_refreshes_to ->(message) { [ message.board, :messages ] }
end

message = Message.new
board = Board.new

message.broadcast_remove_to board, :messages
message.broadcast_remove
message.broadcast_replace_to board, partial: "messages/message"
message.broadcast_replace
message.broadcast_update_to board
message.broadcast_update
message.broadcast_before_to board, target: "message_1"
message.broadcast_after_to board, targets: ".message"
message.broadcast_append_to board, target: "messages"
message.broadcast_append
message.broadcast_prepend_to board, target: "messages"
message.broadcast_prepend
message.broadcast_refresh_to board
message.broadcast_refresh
message.broadcast_action_to board, action: :append, attributes: { method: "morph" }
message.broadcast_action :append, target: "messages"

message.broadcast_replace_later_to board
message.broadcast_replace_later
message.broadcast_update_later_to board
message.broadcast_update_later
message.broadcast_append_later_to board, target: "messages"
message.broadcast_append_later
message.broadcast_prepend_later_to board, target: "messages"
message.broadcast_prepend_later
message.broadcast_refresh_later_to board
message.broadcast_refresh_later
message.broadcast_action_later_to board, action: :append
message.broadcast_action_later action: :append

message.broadcast_render locals: { message: message }
message.broadcast_render_to board
message.broadcast_render_later
message.broadcast_render_later_to board

Message.suppressing_turbo_broadcasts { message.broadcast_refresh }
Message.suppressed_turbo_broadcasts?
Message.suppressed_turbo_broadcasts = true
Message.suppressed_turbo_broadcasts
Message.broadcast_target_default
message.suppressed_turbo_broadcasts?
