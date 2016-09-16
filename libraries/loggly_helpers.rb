module LogglyHelpers
  def configure_files(original_files)
    # The .to_h is required because files aren't hashes, but are chef node
    # attributes, which are supposed to be treated as immutable, unless we
    # actually want to override the value (which here, we don't.)
    valid_files(original_files).map(&:to_h).map do |file|
      file['tag'] ||= File.basename(file['filename']).tr('.', '-')
      file['statefile'] ||= "#{file['filename']}.rsyslog_state"
      file
    end
  end

  private def valid_files(original_files)
    original_files.reject do |file|
      !file.is_a?(Hash) || file['filename'].to_s.strip.empty?
    end
  end

  def loggly_format(app_name)
    app_name_initial_caps = app_name.to_s.gsub(/\b(?<!['â`])[a-z]/, &:capitalize)
    "LogglyFormat#{app_name_initial_caps}"
  end

  def tags
    (node.loggly.tags || []).map { |tag| "tag=\\\"#{tag}\\\"" }.join(' ')
  end

  def rsyslog_major_version
    version_cmd = Mixlib::ShellOut.new('rpm -q rsyslog')
    version_cmd.run_command
    response = version_cmd.stdout.chomp
    # will return something like rsyslog-5.8.10-10.el6_6.x86_64
    response.match(/^rsyslog-(\d+)/)[1].to_i
  end

  def set_version6_source(template, source_file)
    resource = run_context.resource_collection.find(template: template)
    resource.source(source_file)
  end

  def app_conf(app_name)
    "#{node.loggly.rsyslog.conf_dir}/21-#{app_name}.conf"
  end
end
