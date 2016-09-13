# This is the current suggested size from loggly.
normal.rsyslog.max_message_size = '64k'

default.loggly.tags = []

default.loggly.log_files = []
default.loggly.apps = {}

default.loggly.tls.cert_path = '/etc/rsyslog.d/keys/ca.d'
default.loggly.tls.cert_file = 'logs-01.loggly.com_sha12.crt'
default.loggly.tls.cert_url = 'https://logdog.loggly.com/media/logs-01.loggly.com_sha12.crt'
default.loggly.tls.cert_checksum = 'b562ae82b54bcb43923290e78949153c0c64910d40b02d2207010bb119147ffc'

default.loggly.token = ''

default.loggly.rsyslog.conf_dir = '/etc/rsyslog.d'
default.loggly.rsyslog.conf = "#{node.loggly.rsyslog.conf_dir}/22-loggly.conf"
default.loggly.rsyslog.files_conf = "#{node.loggly.rsyslog.conf_dir}/99-files.conf"

default.loggly.rsyslog.host = 'logs-01.loggly.com'
default.loggly.rsyslog.port = 6514

default.loggly.rsyslog.input_file_poll_interval = 10
