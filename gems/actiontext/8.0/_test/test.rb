require "actiontext"

class Article < ActiveRecord::Base
  has_rich_text :content
  has_rich_text :summary, store_if_blank: false
end
