require 'spec_helper'

RSpec.describe Specinfra::Command::Windows::Base::File do
  describe 'methods' do
    subject  { should respond_to(:check_is_file).with(1).arguments  }
    subject  { should respond_to(:check_is_directory).with(1).arguments  }
    subject  { should respond_to(:check_is_hidden).with(1).arguments  }
    subject  { should respond_to(:check_is_system).with(1).arguments  }
    subject  { should respond_to(:check_is_symlink).with(1).arguments  }
    subject  { should respond_to(:check_is_readonly).with(1).arguments  }
    subject  { should respond_to(:check_is_readable).with(2).arguments  }
    subject  { should respond_to(:check_is_writable).with(2).arguments  }
    subject  { should respond_to(:check_is_owned_by).with(2).arguments  }
  end

  describe 'check_is_file' do
      let(:file) { 'file' } 
      let(:attr)  { 'Archive' }
      it {
        expect(described_class).to receive(:item_has_attribute).with( file, attr)
        described_class.check_is_file file
      }
    end
  describe 'check_is_symlink' do
      let(:file) { 'file' } 
      let(:attr)  { 'ReparsePoint' }
      it {
        expect(described_class).to receive(:item_has_attribute).with( file, attr)
        described_class.check_is_symlink file
      }
    end


end
