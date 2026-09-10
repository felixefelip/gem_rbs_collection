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

# `in_batches` without a block returns a `BatchEnumerator`, whose `delete_all`,
# `update_all`, `touch_all` and `destroy_all` run the operation batch by batch.
class TestInBatches < ActiveRecord::Base
  def self.batches
    where(id: 1).in_batches.destroy_all.succ
    where(id: 1).in_batches(of: 100).delete_all.succ
    where(id: 1).in_batches.update_all(name: "x").succ
    where(id: 1).in_batches.touch_all.succ

    in_batches.destroy_all.succ

    where(id: 1).in_batches.each { |relation| relation.update_all(name: "x") }
    where(id: 1).in_batches.each_record { |record| record.own_method }

    # `find_in_batches` without a block returns an Enumerator over the batches.
    where(id: 1).find_in_batches.each { |records| records.each { |record| record.own_method } }
    find_in_batches.each { |records| records.first&.own_method }

    # The block form still type-checks, and still yields a relation.
    where(id: 1).in_batches { |relation| relation.update_all(name: "x") }
  end

  def own_method
  end
end

# `group` answers an `ActiveRecord::Relation::Grouped`, so the rest of the chain
# still has a type: `having` is declared only there, `exists?` still answers
# `bool`, and the calculations answer the hash a grouped query actually returns.
class TestGroupedRelation < ActiveRecord::Base
  def self.grouped
    # @type var grouped_exists: bool
    grouped_exists = where(id: 1)
      .group(:name)
      .having("COUNT(*) >= ?", 3)
      .having("COUNT(DISTINCT author_id) >= ?", 2)
      .exists?

    # Grouping is sticky: the methods that spawn a new relation keep it, so a
    # `having` after an `order` still resolves.
    group(:name).where(id: 1).order(:name).having("COUNT(*) > 0").count.each_key { |key| key }

    # A grouped calculation answers a hash keyed by the grouped column, not the
    # scalar an ungrouped relation would give.
    group(:name).count.each_pair { |_key, value| value.succ }
    group(:name).maximum(:id).each_key { |key| key }

    # The block form of `count` is `Enumerable#count` over the loaded records,
    # not a calculation at all, so it keeps its scalar.
    group(:name).count { |record| record.own_method }.succ

    # And the records themselves are still reachable.
    group(:name).first&.own_method
  end

  def own_method
  end
end
