# frozen_string_literal: true

# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

RSpec.describe OpenStudioMeasureTester::MinitestResult do
  it 'should produce a markdown table' do
    dir = 'spec/files'
    gha_reporter = OpenStudioMeasureTester::GithubActionsReport.new(dir)
    gha_reporter.make_minitest_step_summary_table

    expected = [
       "| Metric           | Value  |",
       "| ---------------- | ------ |",
       "| Total Tests      | 16     |",
       "| Load Error       | 0      |",
       "| Passed           | 13     |",
       "| Success Rate     | 86.67% |",
       "| Failures         | 1      |",
       "| Errors           | 1      |",
       "| Skipped          | 1      |",
       "| Incompatible     | 1      |",
       "| Total Assertions | 120    |",
    ]

    expect(gha_reporter.minitest_summary_table).to eq expected.join("\n")
  end
end

RSpec.describe OpenStudioMeasureTester::MinitestResult do
  it 'should produce annotations' do
    dir = 'spec/files'
    gha_reporter = OpenStudioMeasureTester::GithubActionsReport.new(dir)
    gha_reporter.make_minitest_annotations

    expect(gha_reporter.all_annotations.size).to eq 3
  end
end
