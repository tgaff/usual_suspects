require 'spec_helper'
require 'rake'
require 'byebug'
require 'tempfile'

RSpec.describe 'UsualSuspects' do

 before do
    @rake = Rake::Application.new
    Rake.application = @rake

    # Rake's rake_require tries to be too clever and won't reload from the file for successive RSpec runs
    Rake.load_rakefile 'lib/tasks/usual_suspects.rake'
    #Rake::Task.define_task(:environment)
    #Rake.application.rake_require 'tasks/usual_suspects'
    #Rake.application.rake_require '../lib/tasks/usual_suspects'
  end

 after do
   Rake.application = nil
 end
 describe 'rake task methods' do
    describe '.substitute' do
      let(:initial_text) { "this has an xx but should have a yy" }
      let(:expected_text) { "this has an yy but should have a yy" }

      it 'returns text replacing one string with another' do
        expect( substitute(initial_text, 'xx', 'yy')).to eq expected_text
      end
    end

    describe '.find_and_replace_in_file' do
      let(:temp_file) { Tempfile.new('asdf') }
      before do
        15.times { temp_file.puts '12341-234 o' }
        temp_file.close(unlink_now=false)
      end

      it 'replaces the text in a file' do
        file_path = temp_file.path
        find_and_replace_in_file(file_path, '1', 'o')
        File.open(file_path).each do |line|
          expect(line).to eq "o234o-234 o\n" # warning, this can pass if the file is empty
        end
      end

      it "doesn't add stray bytes" do # test to counter above warning
        expect{ find_and_replace_in_file(temp_file.path, '3', '4')}.to_not change {temp_file.size}
      end

      after do
        temp_file.unlink
      end
    end

    describe '.replace_file' do
      let(:original_file) { Tempfile.new('original') }
      let(:replacement_file) { Tempfile.new('replacement') }

      before do
        original_file.write 'all original'
        replacement_file.write 'replace with me'
        original_file.close false
        replacement_file.close false
      end
      it 'overwrites file x with file y' do
        puts original_file.path, replacement_file.path
        replace_file(replacement_file.path, original_file.path)

        expect(File.read(original_file.path)).to eq 'replace with me'
      end
    end
  end

  describe 'tasks' do
    describe 'rename_application' do
      subject(:task) { @rake["usual_suspects:rename_application"] }
      it 'requires a new name to be specified' do
        expect{task.invoke}.to raise_error
      end
      let(:new_name) { 'TootinPutin' }
      it 'changes the title in application.html.erb' do
        task.invoke(new_name)
        fname = 'app/views/layouts/application.html.erb'
        expect(exists_in_file?(fname, 'UsualSuspects')).to be_falsey
      end
      it 'changes the title in application.rb' do
        task.invoke(new_name)
        fname = 'config/application.erb'
        expect(exists_in_file?(fname, 'UsualSuspects')).to be_falsey
        expect(exists_in_file?(fname, new_name)).to be true
      end

    end

    def exists_in_file?(fname, string)
      File.open(fname).grep(/#{string}/).length > 0
    end
  end
end

