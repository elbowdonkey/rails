# frozen_string_literal: true

require "cases/helper"
require "models/numeric_data"

class NumericalityValidationTest < ActiveRecord::TestCase
  def setup
    @model_class = NumericData.dup
  end

  attr_reader :model_class

  def test_column_with_precision
    model_class.validates_numericality_of(
      :bank_balance, equal_to: 10_000_000.12
    )

    subject = model_class.new(bank_balance: 10_000_000.121)

    assert_predicate subject, :valid?
  end

  def test_column_with_precision_higher_than_double_fig
    model_class.validates_numericality_of(
      :decimal_number_big_precision, equal_to: 10_000_000.3
    )

    subject = model_class.new(decimal_number_big_precision: 10_000_000.3)

    assert_predicate subject, :valid?
  end

  def test_no_column_precision
    model_class.validates_numericality_of(
      :decimal_number, equal_to: 1_000_000_000.123454
    )

    subject = model_class.new(decimal_number: 1_000_000_000.1234545)

    assert_predicate subject, :valid?
  end

  def test_virtual_attribute
    model_class.attribute(:virtual_decimal_number, :decimal)
    model_class.validates_numericality_of(
      :virtual_decimal_number, equal_to: 1_000_000_000.123454
    )

    subject = model_class.new(virtual_decimal_number: 1_000_000_000.1234545)

    assert_predicate subject, :valid?
  end

  def test_on_abstract_class
    abstract_class = Class.new(ActiveRecord::Base) do
      self.abstract_class = true
      validates(:bank_balance, numericality: { equal_to: 10_000_000.12 })
    end

    klass = Class.new(abstract_class) do
      def self.table_name
        "numeric_data"
      end

      def self.name
        "MyClass"
      end
    end
    subject = klass.new(bank_balance: 10_000_000.12)

    assert_predicate(subject, :valid?)
  end
end
