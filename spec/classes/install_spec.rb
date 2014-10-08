require 'spec_helper'

# Start to describe glassfish::install class
describe 'glassfish::install' do
  
  context 'on a RedHat OSFamily' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat'
    } }
    
    describe 'with default param values' do
      # Include required classe with default param values
      let(:pre_condition) { 'include glassfish' }
        
      #
      ## Test default behaviour
      #
      describe 'it should manage user and group' do
        it do
          # Should have a group and user resource
          should contain_group('glassfish').with_ensure('present')
          should contain_user('glassfish').with({
            'ensure' => 'present',
            'managehome' => true,
            'comment'    => 'Glassfish user account',
            'gid'        => 'glassfish',
          }).that_requires('Group[glassfish]').that_comes_before('Exec[change-ownership]')
        end
      end
      
      describe 'it should install glassfish using a zip' do
        it do
          # Anchors
          should contain_anchor('glassfish::install::start')
          should contain_anchor('glassfish::install::end')
          
          # Temp dir 
          should contain_file('/tmp').with_ensure('directory').that_requires('Anchor[glassfish::install::start]')
          
          # Download exec
          should contain_exec('download_glassfish-3.1.2.2.zip').with({
            'command' => 'wget -q http://download.java.net/glassfish/3.1.2.2/release/glassfish-3.1.2.2.zip -O /tmp/glassfish-3.1.2.2.zip',
            'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
            'creates' => '/tmp/glassfish-3.1.2.2.zip',
            'timeout' => '300'
          }).that_requires('File[/tmp]')
          
          # Unzip exec
          should contain_exec('unzip-downloaded').with({
            'command' => 'unzip /tmp/glassfish-3.1.2.2.zip',
            'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
            'cwd'     => '/tmp',
            'creates' => '/usr/local/glassfish-3.1.2.2',
          }).that_requires('Exec[download_glassfish-3.1.2.2.zip]')
          
          # Chown exec
          should contain_exec('change-ownership').with({
            'command' => 'chown -R glassfish:glassfish /tmp/glassfish3',
            'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
            'creates' => '/usr/local/glassfish-3.1.2.2',
          }).that_requires('Exec[unzip-downloaded]')
          
          # Chmod exec
          should contain_exec('change-mode').with({
            'command' => 'chmod -R g+rwX /tmp/glassfish3',
            'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
            'creates' => '/usr/local/glassfish-3.1.2.2',
          }).that_requires('Exec[change-ownership]')
          
          # Move exec
          should contain_exec('move-glassfish3').with({
            'command' => 'mv /tmp/glassfish3 /usr/local/glassfish-3.1.2.2',
            'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
            'cwd'     => '/tmp',
            'creates' => '/usr/local/glassfish-3.1.2.2',
          }).that_requires('Exec[change-mode]')
          
          # Remove-domain1 exec
          should contain_file('remove-domain1').with({
            'ensure' => 'absent',
            'path'   => '/usr/local/glassfish-3.1.2.2/glassfish/domains/domain1',
            'force'  => true
          }).that_requires('Exec[move-glassfish3]').that_comes_before('Anchor[glassfish::install::end]')
        end
      end  
    end    
  end
  
  context 'with glassfish_version => 4.0' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat'
    } }
    
    # Include required classe with default param values
    let(:pre_condition) { 'class {"glassfish": 
      version => "4.0"}' 
    }
    
    describe 'it should install glassfish 4.0 using a zip' do
      it do
        # Anchors
        should contain_anchor('glassfish::install::start')
        should contain_anchor('glassfish::install::end')
        
        # Temp dir 
        should contain_file('/tmp').with_ensure('directory').that_requires('Anchor[glassfish::install::start]')
        
        # Download exec
        should contain_exec('download_glassfish-4.0.zip').with({
          'command' => 'wget -q http://download.java.net/glassfish/4.0/release/glassfish-4.0.zip -O /tmp/glassfish-4.0.zip',
          'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          'creates' => '/tmp/glassfish-4.0.zip',
          'timeout' => '300'
        }).that_requires('File[/tmp]')
        
        # Unzip exec
        should contain_exec('unzip-downloaded').with({
          'command' => 'unzip /tmp/glassfish-4.0.zip',
          'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          'cwd'     => '/tmp',
          'creates' => '/usr/local/glassfish-4.0',
        }).that_requires('Exec[download_glassfish-4.0.zip]')
        
        # Chown exec
        should contain_exec('change-ownership').with({
          'command' => 'chown -R glassfish:glassfish /tmp/glassfish4',
          'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          'creates' => '/usr/local/glassfish-4.0',
        }).that_requires('Exec[unzip-downloaded]')
        
        # Chmod exec
        should contain_exec('change-mode').with({
          'command' => 'chmod -R g+rwX /tmp/glassfish4',
          'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          'creates' => '/usr/local/glassfish-4.0',
        }).that_requires('Exec[change-ownership]')
        
        # Move exec
        should contain_exec('move-glassfish4').with({
          'command' => 'mv /tmp/glassfish4 /usr/local/glassfish-4.0',
          'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          'cwd'     => '/tmp',
          'creates' => '/usr/local/glassfish-4.0',
        }).that_requires('Exec[change-mode]')
        
        # Remove-domain1 exec
        should contain_file('remove-domain1').with({
          'ensure' => 'absent',
          'path'   => '/usr/local/glassfish-4.0/glassfish/domains/domain1',
          'force'  => true
        }).that_requires('Exec[move-glassfish4]').that_comes_before('Anchor[glassfish::install::end]')
      end
    end
  end
  
  context 'with a custom username and password' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat'
    } }
    
    # Include required classe with default param values
    let(:pre_condition) { 'class {"glassfish": 
      user => "gftest", 
      group => "gftest"}' 
    }
      
    # Should create the group and user
    describe 'it should manage user and group' do
      it do
        # Should have a group and user resource
        should contain_group('gftest').with_ensure('present')
        should contain_user('gftest').with({
          'ensure' => 'present',
          'managehome' => true,
          'comment'    => 'Glassfish user account',
          'gid'        => 'gftest',
        }).that_requires('Group[gftest]').that_comes_before('Exec[change-ownership]')
      end
    end
  end
  
  context 'with a install method of yum' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat'
    } }
    
    # Include required classe with default param values
    let(:pre_condition) { 'class {"glassfish": 
      install_method => "package"}' 
    }
      
    # Should attempt to install using yum package
    it do
      # Anchors
      should contain_anchor('glassfish::install::start')
      should contain_anchor('glassfish::install::end')
      
      # Package install
      should contain_package('glassfish3-3.1.2.2').with_ensure('present').that_requires('User[glassfish]').
        that_requires('Anchor[glassfish::install::start]').that_comes_before('Anchor[glassfish::install::end]')
    end
  end
  
  context 'with install method of yum and a custom package prefix' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat'
    } }
    
    # Include required classe with default param values
    let(:pre_condition) { 'class {"glassfish": 
      install_method => "package", 
      package_prefix => "gftest"}' 
    }
      
    # Should attempt to install using yum package
    it do
      # Anchors
      should contain_anchor('glassfish::install::start')
      should contain_anchor('glassfish::install::end')
      
      # Package install
      should contain_package('gftest-3.1.2.2').with_ensure('present').that_requires('User[glassfish]').
        that_requires('Anchor[glassfish::install::start]').that_comes_before('Anchor[glassfish::install::end]')
    end
  end
  
  context 'with manage_accounts => false' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat'
    } }
    
    # Include required classe with default param values
    let(:pre_condition) { 'class {"glassfish": 
      manage_accounts => false}' 
    }
      
    # Should attempt to install using yum package
    it do
      should_not contain_group('glassfish')
      should_not contain_user('glassfish')
    end
  end
  
  context 'with remove_default_domain => false' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat'
    } }
    
    # Include required classe with default param values
    let(:pre_condition) { 'class {"glassfish": 
      remove_default_domain => false}' 
    }
      
    # Should not attempt to remove domain1 
    it do
      should_not contain_file('remove-domain1')
    end
  end


  context 'with an unsupported installation method' do
    # Set the osfamily fact
    let(:facts) { {
      :osfamily => 'RedHat'
    } }
    
    # Include required classe with default param values
    let(:pre_condition) { 'class {"glassfish": 
      install_method => "bob"}' 
    }
    
    # It should fail
    it do
      should compile.and_raise_error(/Unrecognised Installation method bob. Choose one of: 'package','zip'./)
    end 
  end
  
end
