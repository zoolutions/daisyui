# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Validators, "validators" do
  it "is any" do
    expect(described_class::IS_ANY.call).to be_truthy
    expect(described_class::IS_ANY.call("")).to be_truthy
    expect(described_class::IS_ANY.call("something")).to be_truthy
  end

  it "is any non arbitrary" do
    expect(described_class::IS_ANY_NON_ARBITRARY.call("test")).to be_truthy
    expect(described_class::IS_ANY_NON_ARBITRARY.call("1234-hello-world")).to be_truthy
    expect(described_class::IS_ANY_NON_ARBITRARY.call("[hello")).to be_truthy
    expect(described_class::IS_ANY_NON_ARBITRARY.call("hello]")).to be_truthy
    expect(described_class::IS_ANY_NON_ARBITRARY.call("[)")).to be_truthy
    expect(described_class::IS_ANY_NON_ARBITRARY.call("(hello]")).to be_truthy

    expect(described_class::IS_ANY_NON_ARBITRARY.call("[test]")).to be_falsey
    expect(described_class::IS_ANY_NON_ARBITRARY.call("[label:test]")).to be_falsey
    expect(described_class::IS_ANY_NON_ARBITRARY.call("(test)")).to be_falsey
    expect(described_class::IS_ANY_NON_ARBITRARY.call("(label:test)")).to be_falsey
  end

  it "is named container query" do
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("@container/sidebar")).to be_truthy
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("@container-normal/sidebar")).to be_truthy
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("@container-size/sidebar")).to be_truthy
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("@container/[sidebar]")).to be_truthy
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("@container-size/(--sidebar)")).to be_truthy

    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("@container")).to be_falsey
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("@container-normal")).to be_falsey
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("@container-size")).to be_falsey
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("@container/")).to be_falsey
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("@container-normal/")).to be_falsey
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("@container-size/")).to be_falsey
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("@container-[size]/sidebar")).to be_falsey
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("@container-foo/sidebar")).to be_falsey
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("container/sidebar")).to be_falsey
    expect(described_class::IS_NAMED_CONTAINER_QUERY.call("hover:@container/sidebar")).to be_falsey
  end

  it "is arbitrary family name" do
    expect(described_class::IS_ARBITRARY_FAMILY_NAME.call("[family-name:Open_Sans]")).to be_truthy
    expect(described_class::IS_ARBITRARY_FAMILY_NAME.call("[family-name:var(--my-font)]")).to be_truthy

    expect(described_class::IS_ARBITRARY_FAMILY_NAME.call("[Open_Sans]")).to be_falsey
    expect(described_class::IS_ARBITRARY_FAMILY_NAME.call("[number:400]")).to be_falsey
    expect(described_class::IS_ARBITRARY_FAMILY_NAME.call("[weight:400]")).to be_falsey
    expect(described_class::IS_ARBITRARY_FAMILY_NAME.call("family-name:test")).to be_falsey
    expect(described_class::IS_ARBITRARY_FAMILY_NAME.call("(family-name:test)")).to be_falsey
  end

  it "is arbitrary image" do
    expect(described_class::IS_ARBITRARY_IMAGE.call("[url:var(--my-url)]")).to be_truthy
    expect(described_class::IS_ARBITRARY_IMAGE.call("[url(something)]")).to be_truthy
    expect(described_class::IS_ARBITRARY_IMAGE.call("[url:bla]")).to be_truthy
    expect(described_class::IS_ARBITRARY_IMAGE.call("[image:bla]")).to be_truthy
    expect(described_class::IS_ARBITRARY_IMAGE.call("[linear-gradient(something)]")).to be_truthy
    expect(described_class::IS_ARBITRARY_IMAGE.call("[repeating-conic-gradient(something)]")).to be_truthy

    expect(described_class::IS_ARBITRARY_IMAGE.call("[var(--my-url)]")).to be_falsey
    expect(described_class::IS_ARBITRARY_IMAGE.call("[bla]")).to be_falsey
    expect(described_class::IS_ARBITRARY_IMAGE.call("url:2px")).to be_falsey
    expect(described_class::IS_ARBITRARY_IMAGE.call("url(2px)")).to be_falsey
  end

  it "is arbitrary length" do
    expect(described_class::IS_ARBITRARY_LENGTH.call("[3.7%]")).to be_truthy
    expect(described_class::IS_ARBITRARY_LENGTH.call("[481px]")).to be_truthy
    expect(described_class::IS_ARBITRARY_LENGTH.call("[19.1rem]")).to be_truthy
    expect(described_class::IS_ARBITRARY_LENGTH.call("[50vw]")).to be_truthy
    expect(described_class::IS_ARBITRARY_LENGTH.call("[56vh]")).to be_truthy
    expect(described_class::IS_ARBITRARY_LENGTH.call("[length:var(--arbitrary)]")).to be_truthy

    expect(described_class::IS_ARBITRARY_LENGTH.call("1")).to be_falsey
    expect(described_class::IS_ARBITRARY_LENGTH.call("3px")).to be_falsey
    expect(described_class::IS_ARBITRARY_LENGTH.call("1d5")).to be_falsey
    expect(described_class::IS_ARBITRARY_LENGTH.call("[1]")).to be_falsey
    expect(described_class::IS_ARBITRARY_LENGTH.call("[12px")).to be_falsey
    expect(described_class::IS_ARBITRARY_LENGTH.call("12px]")).to be_falsey
    expect(described_class::IS_ARBITRARY_LENGTH.call("one")).to be_falsey
    expect(described_class::IS_ARBITRARY_LENGTH.call("[color(display-p3_1_0_0/50%)]")).to be_falsey
    expect(described_class::IS_ARBITRARY_LENGTH.call("[light-dark(white,rgb(0_0_0/50%))]")).to be_falsey
  end

  it "is arbitrary number" do
    expect(described_class::IS_ARBITRARY_NUMBER.call("[number:black]")).to be_truthy
    expect(described_class::IS_ARBITRARY_NUMBER.call("[number:bla]")).to be_truthy
    expect(described_class::IS_ARBITRARY_NUMBER.call("[number:230]")).to be_truthy
    expect(described_class::IS_ARBITRARY_NUMBER.call("[450]")).to be_truthy

    expect(described_class::IS_ARBITRARY_NUMBER.call("[2px]")).to be_falsey
    expect(described_class::IS_ARBITRARY_NUMBER.call("[bla]")).to be_falsey
    expect(described_class::IS_ARBITRARY_NUMBER.call("[black]")).to be_falsey
    expect(described_class::IS_ARBITRARY_NUMBER.call("black")).to be_falsey
    expect(described_class::IS_ARBITRARY_NUMBER.call("450")).to be_falsey
  end

  it "is arbitrary position" do
    expect(described_class::IS_ARBITRARY_POSITION.call("[position:2px]")).to be_truthy
    expect(described_class::IS_ARBITRARY_POSITION.call("[position:bla]")).to be_truthy
    expect(described_class::IS_ARBITRARY_POSITION.call("[percentage:bla]")).to be_truthy

    expect(described_class::IS_ARBITRARY_POSITION.call("[2px]")).to be_falsey
    expect(described_class::IS_ARBITRARY_POSITION.call("[bla]")).to be_falsey
    expect(described_class::IS_ARBITRARY_POSITION.call("position:2px")).to be_falsey
  end

  it "is arbitrary shadow" do
    expect(described_class::IS_ARBITRARY_SHADOW.call("[0_35px_60px_-15px_rgba(0,0,0,0.3)]")).to be_truthy
    expect(described_class::IS_ARBITRARY_SHADOW.call("[inset_0_1px_0,inset_0_-1px_0]")).to be_truthy
    expect(described_class::IS_ARBITRARY_SHADOW.call("[0_0_#00f]")).to be_truthy
    expect(described_class::IS_ARBITRARY_SHADOW.call("[.5rem_0_rgba(5,5,5,5)]")).to be_truthy
    expect(described_class::IS_ARBITRARY_SHADOW.call("[-.5rem_0_#123456]")).to be_truthy
    expect(described_class::IS_ARBITRARY_SHADOW.call("[0.5rem_-0_#123456]")).to be_truthy
    expect(described_class::IS_ARBITRARY_SHADOW.call("[0.5rem_-0.005vh_#123456]")).to be_truthy
    expect(described_class::IS_ARBITRARY_SHADOW.call("[0.5rem_-0.005vh]")).to be_truthy

    expect(described_class::IS_ARBITRARY_SHADOW.call("[rgba(5,5,5,5)]")).to be_falsey
    expect(described_class::IS_ARBITRARY_SHADOW.call("[#00f]")).to be_falsey
    expect(described_class::IS_ARBITRARY_SHADOW.call("[something-else]")).to be_falsey
  end

  it "is arbitrary weight" do
    expect(described_class::IS_ARBITRARY_WEIGHT.call("[weight:400]")).to be_truthy
    expect(described_class::IS_ARBITRARY_WEIGHT.call("[weight:bold]")).to be_truthy
    expect(described_class::IS_ARBITRARY_WEIGHT.call("[number:400]")).to be_truthy
    expect(described_class::IS_ARBITRARY_WEIGHT.call("[number:var(--my-weight)]")).to be_truthy
    expect(described_class::IS_ARBITRARY_WEIGHT.call("[400]")).to be_truthy
    expect(described_class::IS_ARBITRARY_WEIGHT.call("[bold]")).to be_truthy

    expect(described_class::IS_ARBITRARY_WEIGHT.call("[family-name:test]")).to be_falsey
    expect(described_class::IS_ARBITRARY_WEIGHT.call("weight:400")).to be_falsey
    expect(described_class::IS_ARBITRARY_WEIGHT.call("(weight:400)")).to be_falsey
  end

  it "is arbitrary size" do
    expect(described_class::IS_ARBITRARY_SIZE.call("[size:2px]")).to be_truthy
    expect(described_class::IS_ARBITRARY_SIZE.call("[size:bla]")).to be_truthy
    expect(described_class::IS_ARBITRARY_SIZE.call("[length:bla]")).to be_truthy

    expect(described_class::IS_ARBITRARY_SIZE.call("[2px]")).to be_falsey
    expect(described_class::IS_ARBITRARY_SIZE.call("[bla]")).to be_falsey
    expect(described_class::IS_ARBITRARY_SIZE.call("size:2px")).to be_falsey
    expect(described_class::IS_ARBITRARY_SIZE.call("[percentage:bla]")).to be_falsey
  end

  it "is arbitrary value" do
    expect(described_class::IS_ARBITRARY_VALUE.call("[1]")).to be_truthy
    expect(described_class::IS_ARBITRARY_VALUE.call("[bla]")).to be_truthy
    expect(described_class::IS_ARBITRARY_VALUE.call("[not-an-arbitrary-value?]")).to be_truthy
    expect(described_class::IS_ARBITRARY_VALUE.call("[auto,auto,minmax(0,1fr),calc(100vw-50%)]")).to be_truthy

    expect(described_class::IS_ARBITRARY_VALUE.call("[]")).to be_falsey
    expect(described_class::IS_ARBITRARY_VALUE.call("[1")).to be_falsey
    expect(described_class::IS_ARBITRARY_VALUE.call("1]")).to be_falsey
    expect(described_class::IS_ARBITRARY_VALUE.call("1")).to be_falsey
    expect(described_class::IS_ARBITRARY_VALUE.call("one")).to be_falsey
    expect(described_class::IS_ARBITRARY_VALUE.call("o[n]e")).to be_falsey
  end

  it "is arbitrary variable" do
    expect(described_class::IS_ARBITRARY_VARIABLE.call("(1)")).to be_truthy
    expect(described_class::IS_ARBITRARY_VARIABLE.call("(bla)")).to be_truthy
    expect(described_class::IS_ARBITRARY_VARIABLE.call("(not-an-arbitrary-value?)")).to be_truthy
    expect(described_class::IS_ARBITRARY_VARIABLE.call("(--my-arbitrary-variable)")).to be_truthy
    expect(described_class::IS_ARBITRARY_VARIABLE.call("(label:--my-arbitrary-variable)")).to be_truthy

    expect(described_class::IS_ARBITRARY_VARIABLE.call("()")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE.call("(1")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE.call("1)")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE.call("1")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE.call("one")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE.call("o(n)e")).to be_falsey
  end

  it "is arbitrary variable family name" do
    expect(described_class::IS_ARBITRARY_VARIABLE_FAMILY_NAME.call("(family-name:test)")).to be_truthy

    expect(described_class::IS_ARBITRARY_VARIABLE_FAMILY_NAME.call("(other:test)")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_FAMILY_NAME.call("(test)")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_FAMILY_NAME.call("family-name:test")).to be_falsey
  end

  it "is arbitrary variable image" do
    expect(described_class::IS_ARBITRARY_VARIABLE_IMAGE.call("(image:test)")).to be_truthy
    expect(described_class::IS_ARBITRARY_VARIABLE_IMAGE.call("(url:test)")).to be_truthy

    expect(described_class::IS_ARBITRARY_VARIABLE_IMAGE.call("(other:test)")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_IMAGE.call("(test)")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_IMAGE.call("image:test")).to be_falsey
  end

  it "is arbitrary variable length" do
    expect(described_class::IS_ARBITRARY_VARIABLE_LENGTH.call("(length:test)")).to be_truthy

    expect(described_class::IS_ARBITRARY_VARIABLE_LENGTH.call("(other:test)")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_LENGTH.call("(test)")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_LENGTH.call("length:test")).to be_falsey
  end

  it "is arbitrary variable position" do
    expect(described_class::IS_ARBITRARY_VARIABLE_POSITION.call("(position:test)")).to be_truthy

    expect(described_class::IS_ARBITRARY_VARIABLE_POSITION.call("(other:test)")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_POSITION.call("(test)")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_POSITION.call("position:test")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_POSITION.call("percentage:test")).to be_falsey
  end

  it "is arbitrary variable shadow" do
    expect(described_class::IS_ARBITRARY_VARIABLE_SHADOW.call("(shadow:test)")).to be_truthy
    expect(described_class::IS_ARBITRARY_VARIABLE_SHADOW.call("(test)")).to be_truthy

    expect(described_class::IS_ARBITRARY_VARIABLE_SHADOW.call("(other:test)")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_SHADOW.call("shadow:test")).to be_falsey
  end

  it "is arbitrary variable size" do
    expect(described_class::IS_ARBITRARY_VARIABLE_SIZE.call("(size:test)")).to be_truthy
    expect(described_class::IS_ARBITRARY_VARIABLE_SIZE.call("(length:test)")).to be_truthy

    expect(described_class::IS_ARBITRARY_VARIABLE_SIZE.call("(other:test)")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_SIZE.call("(test)")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_SIZE.call("size:test")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_SIZE.call("percentage:test")).to be_falsey
  end

  it "is arbitrary variable weight" do
    expect(described_class::IS_ARBITRARY_VARIABLE_WEIGHT.call("(weight:test)")).to be_truthy
    expect(described_class::IS_ARBITRARY_VARIABLE_WEIGHT.call("(number:test)")).to be_truthy
    expect(described_class::IS_ARBITRARY_VARIABLE_WEIGHT.call("(--my-weight)")).to be_truthy

    expect(described_class::IS_ARBITRARY_VARIABLE_WEIGHT.call("(other:test)")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_WEIGHT.call("weight:test")).to be_falsey
    expect(described_class::IS_ARBITRARY_VARIABLE_WEIGHT.call("[weight:test]")).to be_falsey
  end

  it "is fraction" do
    expect(described_class::IS_FRACTION.call("1/2")).to be_truthy
    expect(described_class::IS_FRACTION.call("123/209")).to be_truthy

    expect(described_class::IS_FRACTION.call("1")).to be_falsey
    expect(described_class::IS_FRACTION.call("1/2/3")).to be_falsey
    expect(described_class::IS_FRACTION.call("[1/2]")).to be_falsey
  end

  it "is integer" do
    expect(described_class::IS_INTEGER.call("1")).to be_truthy
    expect(described_class::IS_INTEGER.call("123")).to be_truthy
    expect(described_class::IS_INTEGER.call("8312")).to be_truthy

    expect(described_class::IS_INTEGER.call("[8312]")).to be_falsey
    expect(described_class::IS_INTEGER.call("[2]")).to be_falsey
    expect(described_class::IS_INTEGER.call("[8312px]")).to be_falsey
    expect(described_class::IS_INTEGER.call("[8312%]")).to be_falsey
    expect(described_class::IS_INTEGER.call("[8312rem]")).to be_falsey
    expect(described_class::IS_INTEGER.call("8312.2")).to be_falsey
    expect(described_class::IS_INTEGER.call("1.2")).to be_falsey
    expect(described_class::IS_INTEGER.call("one")).to be_falsey
    expect(described_class::IS_INTEGER.call("1/2")).to be_falsey
    expect(described_class::IS_INTEGER.call("1%")).to be_falsey
    expect(described_class::IS_INTEGER.call("1px")).to be_falsey
  end

  it "is number" do
    expect(described_class::IS_NUMBER.call("1")).to be_truthy
    expect(described_class::IS_NUMBER.call("123")).to be_truthy
    expect(described_class::IS_NUMBER.call("8312")).to be_truthy
    expect(described_class::IS_NUMBER.call("8312.2")).to be_truthy
    expect(described_class::IS_NUMBER.call("1.2")).to be_truthy

    expect(described_class::IS_NUMBER.call("[8312]")).to be_falsey
    expect(described_class::IS_NUMBER.call("[2]")).to be_falsey
    expect(described_class::IS_NUMBER.call("[8312px]")).to be_falsey
    expect(described_class::IS_NUMBER.call("[8312%]")).to be_falsey
    expect(described_class::IS_NUMBER.call("[8312rem]")).to be_falsey
    expect(described_class::IS_NUMBER.call("one")).to be_falsey
    expect(described_class::IS_NUMBER.call("1/2")).to be_falsey
    expect(described_class::IS_NUMBER.call("1%")).to be_falsey
    expect(described_class::IS_NUMBER.call("1px")).to be_falsey
  end

  it "is percent" do
    expect(described_class::IS_PERCENT.call("1%")).to be_truthy
    expect(described_class::IS_PERCENT.call("100.001%")).to be_truthy
    expect(described_class::IS_PERCENT.call(".01%")).to be_truthy
    expect(described_class::IS_PERCENT.call("0%")).to be_truthy

    expect(described_class::IS_PERCENT.call("0")).to be_falsey
    expect(described_class::IS_PERCENT.call("one%")).to be_falsey
  end

  it "is tshirt size" do
    expect(described_class::IS_TSHIRT_SIZE.call("xs")).to be_truthy
    expect(described_class::IS_TSHIRT_SIZE.call("sm")).to be_truthy
    expect(described_class::IS_TSHIRT_SIZE.call("md")).to be_truthy
    expect(described_class::IS_TSHIRT_SIZE.call("lg")).to be_truthy
    expect(described_class::IS_TSHIRT_SIZE.call("xl")).to be_truthy
    expect(described_class::IS_TSHIRT_SIZE.call("2xl")).to be_truthy
    expect(described_class::IS_TSHIRT_SIZE.call("2.5xl")).to be_truthy
    expect(described_class::IS_TSHIRT_SIZE.call("10xl")).to be_truthy
    expect(described_class::IS_TSHIRT_SIZE.call("2xs")).to be_truthy
    expect(described_class::IS_TSHIRT_SIZE.call("2lg")).to be_truthy

    expect(described_class::IS_TSHIRT_SIZE.call("")).to be_falsey
    expect(described_class::IS_TSHIRT_SIZE.call("hello")).to be_falsey
    expect(described_class::IS_TSHIRT_SIZE.call("1")).to be_falsey
    expect(described_class::IS_TSHIRT_SIZE.call("xl3")).to be_falsey
    expect(described_class::IS_TSHIRT_SIZE.call("2xl3")).to be_falsey
    expect(described_class::IS_TSHIRT_SIZE.call("-xl")).to be_falsey
    expect(described_class::IS_TSHIRT_SIZE.call("[sm]")).to be_falsey
  end
end
