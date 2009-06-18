namespace :tmpfs do
  _cset(:tmpfs_directories) do
    abort "Please specify the tmpfs directories:\n  set :tmpfs_directories do\n{\n'/tmpfs' => {:size => '2G', :mode => '0744'},\n}\nend"
  end

  desc "Create tmpfs directories"
  task :create_directories, :roles => :app do
    tmpfs_directories.each do |dir,options|
      options[:size] ||= '2G'
      options[:mode] ||= '0744'
      sudo "mkdir -p #{dir}"
      fstab_line = "tmpfs #{dir} tmpfs size=#{options[:size]},mode=#{options[:mode]} 0 0"
      sudo_add_to_file('/etc/fstab',fstab_line)
      sudo "mount #{dir}"
    end
  end

  desc "Create ftp directories within :vsftpd_tmpfs_directory for each user defined in :vsftpd_users and symlink in their homedirs"
  task :create_vsftpd_tmpfs_dirs, :roles => :app do
    vsftpd_users.each do |target_user|
      sudo "mkdir -p #{File.join(vsftpd_tmpfs_directory,target_user)}"
      sudo "ln -s #{File.join(vsftpd_tmpfs_directory,target_user)} ~#{target_user}/ftp"
      sudo "chown #{target_user}:#{vsftpd_group} ~#{target_user}/ftp"
    end
  end
end