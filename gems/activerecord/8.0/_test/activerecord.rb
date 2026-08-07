class TestCallbackObject < ActiveRecord::Base
  before_validation ::Callbacks::ClassCallback
  after_validation ::Callbacks::ClassCallback
  before_save ::Callbacks::ClassCallback
  before_create ::Callbacks::ClassCallback
  after_create ::Callbacks::ClassCallback
  after_save ::Callbacks::ClassCallback
  around_create ::Callbacks::ClassCallback
  around_save ::Callbacks::ClassCallback
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


# `ActiveRecord::Delegation` delegates a handful of class methods to `model`, so
# they are callable on a relation — including inside a `scope` body, where `self`
# is the relation rather than the class.
class TestRelationDelegation < ActiveRecord::Base
  scope :recent, -> {
    connection
    where(id: 1)
  }

  def self.delegated_on_a_relation
    relation = all
    relation.connection
    relation.with_connection { |conn| conn }
    relation.primary_key
    relation.table_name.upcase
    relation.transaction { 1 }.succ
    relation.sanitize_sql_like("a%b").upcase
    relation.unscoped
    relation.name.upcase
  end
end

# `Model.build` (Rails 7.1+) initializes a record without saving it. Passing an
# Array of attribute hashes builds one record per hash instead.
class TestModelBuild < ActiveRecord::Base
  def self.builds
    build.own_method
    build(name: "x").own_method
    build(name: "x") { |record| record.own_method }.own_method

    records = build([{ name: "x" }, { name: "y" }])
    records.size
    records.each { |record| record.own_method }
  end

  def own_method
  end
end
