# -*- mode: puppet -*-
# vi: set ft=puppet :

define urugeas::jenkins_job_builder (
  String $shell_command                         = lookup('urugeas::shell_command'),
  Array[String] $error_patterns                 = lookup('urugeas::error_patterns'),
  Optional[Array[String]] $fatal_error_patterns = lookup('urugeas::fatal_error_patterns'),
  Optional[String] $tools_path                  = '/tmp',
  Optional[String] $webroot_path                = '/var/www/html',
  $version                                      = '0.1.0'
) {

  validate_string($tools_path)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  $random = fqdn_rand(1000,$::uptime_seconds)
  $taskname = regsubst($name, "[$/\\|:, ]", '_', 'G')
  # Generate shell script
  notify { "${name} shell script (plain)":
    message => $shell_command,
  }
  # NOT:  can not combine expressions due to
  # Error: illegal comma separated argument list
  $error_patterns_str = regsubst(regsubst($error_patterns.join('|'),'^' ,'(?' ,'' ),'$' ,')' ,'')
  # $error_patterns_tmp = $error_patterns.join('|')
  # $error_patterns_str = regsubst(regsubst($error_patterns_tmp,'^' ,'\(\?' ,''),'$' ,'\)' ,'')
  notify { "${name} error patterns(processed)":
    message => $error_patterns_str,
  }
  $cdata = regsubst(regsubst(regsubst(regsubst(regsubst($shell_command, '&', '&amp;', 'G'), '>', '&gt;', 'G'), '<', '&lt;', 'G'), '"', '&quot;', 'G'), "'", '&apos;', 'G')
  notify { "${name} shell script (cdata)":
    message => $cdata,
  }
  $job_xml_template = 'job_xml'
  $job_xml = 'job.xml'
  file { $job_xml:
    ensure  => file,
    path    => "${tools_path}/job.xml",
    content => template("${module_name}/${job_xml_template}.erb"),
    mode    => '0755',
  }
  notify { "Generating Jenkins job ${job_xml} in the ${tools_path}":
    before => File[$job_xml],
  }
  # the replica of the above, but intentionally kept away from the loop
  $index_html_template = 'index_html'
  $index_html = 'index.html'
  file { $index_html:
    ensure  => file,
    path    => "${webroot_path}/${index_html}",
    content => template("${module_name}/${index_html_template}.erb"),
    mode    => '0755',
  }
  notify { "Generating dummy page with the jenkins command ${index_html} in the ${webroot_path}":
    before => File[$index_html],
  }
}
