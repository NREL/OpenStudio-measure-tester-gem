# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

module JUnitType
  MINITEST = 'minitest'
  PYTEST = 'pytest'
  ACCEPTED_VALUES = [MINITEST, PYTEST]

  def self.validate(v)
    raise "Unknow value #{v}: #{ACCEPTED_VALUES}" unless ACCEPTED_VALUES.include?(v)
  end
end


def parse_junit_xunit1(xml_path, junit_type:)

  JUnitType.validate(junit_type)

  doc = REXML::Document.new(File.open(xml_path)).root

  if not doc
    return nil
  end

  testsuite_element = doc.elements['testsuite']
  errors, failures, skipped, annotations = parse_testsuite(testsuite_element, junit_type: junit_type)

  result = {
    #measure_compatibility_errors: json_data[:compatible] ? 0 1
   measure_tests: testsuite_element.attributes['tests'].to_i,
   measure_assertions: testsuite_element.attributes['assertions'].to_i,
   measure_errors: testsuite_element.attributes['errors'].to_i,
   measure_failures: testsuite_element.attributes['failures'].to_i,
   measure_skipped: testsuite_element.attributes['skipped'].to_i,
   issues: {
     errors: errors,
     failures: failures,
     skipped: skipped,
      # compatibility_error: json_data[:compatible] ? 0 1
    },
    annotations: annotations,
  }

  result
end

def parse_testsuite(testsuite_element, junit_type:)
  errors = []
  failures = []
  skipped = []

  JUnitType.validate(junit_type)

  annotations = []
  filepath = nil
  if junit_type == JUnitType::MINITEST
    filepath = testsuite_element.attributes['filepath']
  end

  testsuite_element.elements.each('testcase') do |testcase|
    if testcase.elements['error']
      errors << testcase.elements['error']
    elsif testcase.elements['failure']
      failures << testcase.elements['failure']
    elsif testcase.elements['skipped']
      skipped << 'Skipped test: ' + testcase.elements['skipped'].attributes['type']
    end

    annotations += prepare_testcase_annotations(testcase, junit_type: junit_type, filepath: filepath)
  end

  return errors, failures, skipped, annotations
end

def prepare_testcase_annotations(testcase, junit_type:, filepath: nil)

  annotations = []

  JUnitType.validate(junit_type)
  is_minitest = (junit_type == JUnitType::MINITEST)
  line_key = is_minitest ? 'lineno' : 'line'

  raise "When Minitest, filepath can't be nil" if is_minitest && filepath.nil?


  name = testcase.attributes['name']
  line = testcase.attributes[line_key].to_i
  classname = testcase.attributes['classname']

  # annot = "::error file=#{filepath},line=#{line},endLine=#{line + 1},title=#{title}::#{classname}.#{name}:#{message}"
  testcase.elements.each('failure') do |x|
    title = x.attributes['type']
    message = x.attributes['message']
    if is_minitest
      message = x.attributes['message']
    else
      filepath = testcase.attributes['file']
      message = x.text
    end
    annotations << {
      type: 'error',
      classname: classname,
      name: name,
      file: filepath,
      line: line,
      title: title,
      message: message,
    }
  end
  testcase.elements.each('error') do |x|
    title = x.attributes['type']
    if is_minitest
      message = x.attributes['message']
    else
      filepath = testcase.attributes['file']
      message = x.text
    end
    annotations << {
      type: 'error',
      classname: classname,
      name: name,
      file: filepath,
      line: line,
      title: title,
      message: message,
    }
  end
  testcase.elements.each('skipped') do |x|
    title = x.attributes['type']
    message = x.attributes['message']
    if is_minitest
      message = x.attributes['message']
    else
      filepath = testcase.attributes['file']
      message = x.text
    end
    annotations << {
      type: 'warning',
      classname: classname,
      name: name,
      file: filepath,
      line: line,
      title: title,
      message: message,
    }
  end

  return annotations
end

def format_github_annotation_minitest(annotation_hash)
  "::#{annotation_hash[:type]} file=#{annotation_hash[:file]},line=#{annotation_hash[:line]},endLine=#{annotation_hash[:line] + 1},title=#{annotation_hash[:title]}::#{annotation_hash[:classname]}.#{annotation_hash[:name]}:#{annotation_hash[:message]}"
end
