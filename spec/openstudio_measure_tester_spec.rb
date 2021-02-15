# frozen_string_literal: true

########################################################################################################################
#  OpenStudio(R), Copyright (c) 2008-2021, Alliance for Sustainable Energy, LLC. All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
#  following conditions are met:
#
#  (1) Redistributions of source code must retain the above copyright notice, this list of conditions and the following
#  disclaimer.
#
#  (2) Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#  following disclaimer in the documentation and/or other materials provided with the distribution.
#
#  (3) Neither the name of the copyright holder nor the names of any contributors may be used to endorse or promote
#  products derived from this software without specific prior written permission from the respective party.
#
#  (4) Other than as required in clauses (1) and (2), distributions in any form of modifications or other derivative
#  works may not use the "OpenStudio" trademark, "OS", "os", or any other confusingly similar designation without
#  specific prior written permission from Alliance for Sustainable Energy, LLC.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER, THE UNITED STATES GOVERNMENT, OR ANY CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
#  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
########################################################################################################################

RSpec.describe OpenStudioMeasureTester do
  before :all do
    OpenStudioMeasureTester::RakeTask.new
  end

  it 'has a version number' do
    expect(OpenStudioMeasureTester::VERSION).not_to be nil
  end

  it 'should have new rake tasks' do
    expect(Rake::Task.task_defined?('openstudio:test')).to be true
    expect(Rake::Task.task_defined?('openstudio:rubocop')).to be true
  end

  it 'should load openstudio' do
    require 'openstudio'
    puts "OpenStudio Loaded. Version: #{OpenStudio.openStudioLongVersion}"
  rescue LoadError
    puts 'Could not load OpenStudio'
    expect(false).to eq true
  end

  context 'Measure tests in non-root directory' do
    before :each do
      @curdir = Dir.pwd
      Dir.chdir('spec/test_measures/')
    end

    after :each do
      Dir.chdir(@curdir)
    end

    it 'should run measure tests' do
      require 'openstudio'
      puts "OpenStudio Loaded. Version: #{OpenStudio.openStudioLongVersion}"

      IO.popen('rake openstudio:test') do |io|
        while (line = io.gets)
          puts line
        end
      end
      expect(File.exist?('test_results/minitest/html_reports/index.html')).to eq true
      expect(File.exist?('test_results/minitest/reports/TEST-SetGasBurnerEfficiency-Test.xml')).to eq true
      expect(File.exist?('test_results/minitest/reports/TEST-RotateBuilding-Test.xml')).to eq true
    end

    it 'should run rubocop' do
      IO.popen('rake openstudio:rubocop') do |io|
        while (line = io.gets)
          puts line
        end
      end
      expect(File.exist?('test_results/rubocop/rubocop-results.xml')).to eq true
    end

    it 'should run openstudio style' do
      IO.popen('rake openstudio:style') do |io|
        while (line = io.gets)
          puts line
        end
      end
      expect(File.exist?('test_results/openstudio_style/openstudio_style.json')).to eq true
    end
  end
end
