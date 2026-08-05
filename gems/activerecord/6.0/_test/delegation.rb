class TestRelationDelegation < ActiveRecord::Base
  scope :recent, -> {
    connection
    where(id: 1)
  }

  def self.delegated_on_a_relation
    relation = all
    relation.connection
    relation.primary_key
    relation.table_name.upcase
    relation.transaction { 1 }.succ
    relation.sanitize_sql_like("a%b").upcase
    relation.unscoped
    relation.name.upcase
  end
end
