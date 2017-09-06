Puppet::Type.type(:runlevel).provide(:systemd) do
  desc <<-EOM
    Set the system runlevel using systemd
  EOM

  commands :systemctl => 'systemctl'
  defaultfor :kernel => 'Linux'

  def level
    Facter.value(:runlevel)
  end

  def level=(should)
    return execute([command(:systemctl),'isolate',init2systemd(@resource[:name])])
  end

  def persist
    if execute([command(:systemctl),'get-default']).strip == init2systemd(@resource[:name]) then
      return :true
    else
      return :false
    end
  end

  def persist=(should)
    execute([command(:systemctl),'set-default',init2systemd(@resource[:name])])
  end

  private

  def init2systemd(input)
    runlevel = input

    if input == '5' then
      runlevel = 'graphical.target'
    elsif input == '1' then
      runlevel = 'rescue.target'
    elsif input =~ /^\d+$/ then
      runlevel = 'multi-user.target'
    elsif input !~ /.*\.target/ then
      runlevel = "#{input}.target"
    end

    return runlevel
  end
end
