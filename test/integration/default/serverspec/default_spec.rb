require 'serverspec'

set :backend, :exec

describe service('rsyslog') do
  it { should be_enabled }
  it { should be_running }
end

def expected_working_dir
  if os[:family] == 'ubuntu'
    '/var/spool/rsyslog'
  elsif os[:family] == 'redhat'
    '/var/lib/rsyslog'
  end
end

def rsyslog_version7_and_above?
  os[:family] == 'ubuntu' || os[:family] == 'redhat' && os[:release].to_f >= 7.0
end

def rsyslog_version6_and_below?
  os[:family] == 'redhat' && os[:release].to_f < 7.0
end

describe file('/etc/rsyslog.d/22-loggly.conf') do
  it { should be_file }

  # Common content for all platforms
  content_lines = [
    '$DefaultNetstreamDriverCAFile /etc/rsyslog.d/keys/ca.d/logs-01.loggly.com_sha12.crt',
    '$ActionSendStreamDriver gtls',
    '$ActionSendStreamDriverMode 1',
    '$ActionSendStreamDriverAuthMode x509/name',
    '$ActionSendStreamDriverPermittedPeer *.loggly.com',
    '[test_token@41058 tag=\\"Vagrant\\" tag=\\"test\\"]'
  ]

  if rsyslog_version7_and_above?
    content_lines << 'target="logs-01.loggly.com" port="6514"'
  elsif rsyslog_version6_and_below?
    content_lines << '*.* @@logs-01.loggly.com:6514;LogglyFormat'
  else
    fail 'unsupported platform'
  end

  content_lines << "$WorkDirectory #{expected_working_dir}"

  content_lines.each do |line|
    its(:content) { should match(/#{Regexp.escape(line)}/) }
  end
end

describe file('/etc/rsyslog.d/99-files.conf') do
  it { should be_file }

  if rsyslog_version7_and_above?
    expected_files_conf = <<-EOS.gsub(/^      /, '')
      # This file was generated by Chef

      module(load="imfile" PollingInterval="10")

      input(type="imfile"
            File="/tmp/test.log"
            Tag="test-log"
            Statefile="/tmp/test.log.rsyslog_state"
        )
    EOS
  elsif rsyslog_version6_and_below?
    expected_files_conf = <<-EOS.gsub(/^      /, '')
      # This file was generated by Chef

      $ModLoad imfile
      $InputFilePollInterval 10

      # Input for /tmp/test.log
      $InputFileName /tmp/test.log
      $InputFileTag test-log
      $InputFileStateFile /tmp/test.log.rsyslog_state # This must be unique for each file being polled
      $InputFilePersistStateInterval 20000
      $InputRunFileMonitor
    EOS
  else
    fail 'unsupported platform'
  end

  its(:content) { should eq expected_files_conf }
end

describe file('/etc/rsyslog.d/21-nginx.conf') do
  it { should be_file }

  if rsyslog_version7_and_above?
    expected_apps_conf = <<-EOS.gsub(/^      /, '')
      # This file was generated by Chef

      $ModLoad imfile
      $InputFilePollInterval 10
      $WorkDirectory #{expected_working_dir}

      # Add a tag for nginx app events
      template(name="LogglyFormatNginx" type="string" string="%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% %procid% %msgid% [test_token@41058 tag=\\"nginx\\"] %msg%\\n")

      # Input for /tmp/nginx-access.log
      $InputFileName /tmp/nginx-access.log
      $InputFileTag custom-nginx-access
      $InputFileStateFile /tmp/custom-nginx-state-file
      $InputFilePersistStateInterval 20000
      $InputRunFileMonitor

      # Input for /tmp/nginx-ssl-access.log
      $InputFileName /tmp/nginx-ssl-access.log
      $InputFileTag custom-nginx-access
      $InputFileStateFile /tmp/nginx-ssl-access.log.rsyslog_state
      $InputFilePersistStateInterval 20000
      $InputRunFileMonitor

      # Input for /tmp/nginx-error.log
      $InputFileName /tmp/nginx-error.log
      $InputFileTag nginx-error-log
      $InputFileStateFile /tmp/nginx-error.log.rsyslog_state
      $InputFilePersistStateInterval 20000
      $InputRunFileMonitor


      # Send to Loggly then discard
      if $programname == 'custom-nginx-access' then action(type="omfwd" protocol="tcp" target="logs-01.loggly.com" port="6514" template="LogglyFormatNginx")
      if $programname == 'custom-nginx-access' then ~
      if $programname == 'nginx-error-log' then action(type="omfwd" protocol="tcp" target="logs-01.loggly.com" port="6514" template="LogglyFormatNginx")
      if $programname == 'nginx-error-log' then ~
    EOS
  elsif rsyslog_version6_and_below?
    expected_apps_conf = <<-EOS.gsub(/^      /, '')
      # This file was generated by Chef

      $ModLoad imfile
      $InputFilePollInterval 10
      $WorkDirectory #{expected_working_dir}

      # Add a tag for nginx app events
      $template LogglyFormatNginx,"<%pri%>%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% %procid% %msgid% [test_token@41058 tag=\\"nginx\\"] %msg%\\n"

      # Input for /tmp/nginx-access.log
      $InputFileName /tmp/nginx-access.log
      $InputFileTag custom-nginx-access
      $InputFileStateFile /tmp/custom-nginx-state-file
      $InputFilePersistStateInterval 20000
      $InputRunFileMonitor

      # Input for /tmp/nginx-ssl-access.log
      $InputFileName /tmp/nginx-ssl-access.log
      $InputFileTag custom-nginx-access
      $InputFileStateFile /tmp/nginx-ssl-access.log.rsyslog_state
      $InputFilePersistStateInterval 20000
      $InputRunFileMonitor

      # Input for /tmp/nginx-error.log
      $InputFileName /tmp/nginx-error.log
      $InputFileTag nginx-error-log
      $InputFileStateFile /tmp/nginx-error.log.rsyslog_state
      $InputFilePersistStateInterval 20000
      $InputRunFileMonitor


      # Send to Loggly then discard
      if $programname == 'custom-nginx-access' then @@logs-01.loggly.com:6514;LogglyFormatNginx
      if $programname == 'custom-nginx-access' then ~
      if $programname == 'nginx-error-log' then @@logs-01.loggly.com:6514;LogglyFormatNginx
      if $programname == 'nginx-error-log' then ~
    EOS
  else
    fail 'unsupported platform'
  end

  its(:content) { should eq expected_apps_conf }
end
