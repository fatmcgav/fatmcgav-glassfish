require 'spec_helper_system'

describe 'glassfish' do
  it 'class should install without errors' do
    pp = <<-EOS
      class { 'glassfish': }
    EOS

    puppet_apply(pp) do |r|
      r.exit_code.should == 2
      r.refresh
      r.exit_code.should be_zero
    end
  end
end
