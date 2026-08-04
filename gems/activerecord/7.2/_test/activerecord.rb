class TestCallbackObject < ActiveRecord::Base
  before_validation ::Callbacks::ClassCallback
  after_validation ::Callbacks::ClassCallback
  before_save ::Callbacks::ClassCallback
  before_create ::Callbacks::ClassCallback
  after_create ::Callbacks::ClassCallback
  after_save ::Callbacks::ClassCallback
  around_create ::Callbacks::ClassCallback
  around_save ::Callbacks::ClassCallback

  def local_condition1
    [true, false].sample
  end

  def local_condition2
    [true, false].sample
  end

  def local_condition3
    [true, false].sample
  end

  # https://guides.rubyonrails.org/v7.2/active_record_validations.html#combining-validation-conditions
  RAILS_72_DOCS_EXAMPLE = [
    :local_condition1,
    ->(my_rec) { my_rec.local_condition2 },
    Proc.new do |my_rec|
      # @type var my_rec: TestCallbackObject
      my_rec.local_condition3
    end
  ]

  validate :custom_validation, on: :update, unless: RAILS_72_DOCS_EXAMPLE

  def custom_validation
    if self.record_timestamps?
      self.errors.add(:base, 'testing only')
    end
  end
end

module Callbacks
  class ClassCallback
    def self.before_validation(model_obj)
      puts("class before_validation: #{model_obj}")
    end

    def self.after_validation(model_obj)
      puts("class after_validation: #{model_obj}")
    end

    def self.before_save(model_obj)
      puts("class before_save: #{model_obj}")
    end

    def self.before_create(model_obj)
      puts("class before_create: #{model_obj}")
    end

    def self.after_create(model_obj)
      puts("class after_create: #{model_obj}")
    end

    def self.after_save(model_obj)
      puts("class after_save: #{model_obj}")
    end

    def self.around_create(model_obj)
      puts("class around_create: #{model_obj}")
      yield
    end

    def self.around_save(model_obj)
      puts("class around_save: #{model_obj}")
      yield
    end
  end
end


# `ActiveRecord::Delegation` makes the model's class methods reachable on a
# relation — including inside a `scope` body, where `self` is the relation
# rather than the class.
class TestRelationDelegation < ActiveRecord::Base
  scope :recent, -> {
    connection
    where(id: 1)
  }

  def self.delegated_on_a_relation
    relation = all
    relation.connection
    relation.lease_connection
    relation.with_connection { |conn| conn }
    relation.primary_key
    relation.table_name.upcase
    relation.transaction { 1 }.succ
    relation.sanitize_sql_like("a%b").upcase
    relation.unscoped
    relation.name.upcase
  end
end
