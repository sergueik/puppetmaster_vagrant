# -*- mode: puppet -*-
# vi: set ft=puppet :

define urugeas::jenkins_job_builder (
  String $shell_command                         = lookup('urugeas::shell_command'),
  Array[String] $error_patterns                 = lookup('urugeas::error_patterns'),
  Optional[Array[String]] $fatal_error_patterns = lookup('urugeas::fatal_error_patterns'),
  Optional[String] $tools_path                  = '/tmp',
  Optional[String] $webroot_path                = '/var/www/jenkins',
  String $java_options                          = lookup('urugeas::java_options'),
  $version                                      = '0.2.0'
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
  $error_patterns_regexp_string = regsubst(regsubst($error_patterns.join('|'),'^' ,'(?' ,'' ),'$' ,')' ,'')
  # $error_patterns_tmp = $error_patterns.join('|')
  # $error_patterns_regexp_string = regsubst(regsubst($error_patterns_tmp,'^' ,'\(\?' ,''),'$' ,'\)' ,'')
  notify { "${name} error patterns(processed)":
    message => $error_patterns_regexp_string,
  }

  $fatal_error_patterns_regexp_string = regsubst(regsubst($fatal_error_patterns.join('|'),'^' ,'(?' ,'' ),'$' ,')' ,'')
  # $fatal_error_patterns_tmp = $fatal_error_patterns.join('|')
  # $fatal_error_patterns_regexp_string = regsubst(regsubst($fatal_error_patterns_tmp,'^' ,'\(\?' ,''),'$' ,'\)' ,'')
  notify { "${name} fatal error patterns(processed)":
    message => $fatal_error_patterns_regexp_string,
  }

  $shell_command_cdata = regsubst(regsubst(regsubst(regsubst(regsubst($shell_command, '&', '&amp;', 'G'), '>', '&gt;', 'G'), '<', '&lt;', 'G'), '"', '&quot;', 'G'), "'", '&apos;', 'G')
  $error_patterns_regexp_cdata = regsubst(regsubst(regsubst(regsubst(regsubst($error_patterns_regexp_string, '&', '&amp;', 'G'), '>', '&gt;', 'G'), '<', '&lt;', 'G'), '"', '&quot;', 'G'), "'", '&apos;', 'G')
  $fatal_error_patterns_regexp_cdata = regsubst(regsubst(regsubst(regsubst(regsubst($fatal_error_patterns_regexp_string, '&', '&amp;', 'G'), '>', '&gt;', 'G'), '<', '&lt;', 'G'), '"', '&quot;', 'G'), "'", '&apos;', 'G')

  notify { "${name} shell script (cdata)":
    message => $shell_command_cdata,
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

  urugeas::makepath { "making ${webroot_path}":
    target => $webroot_path,
    before => File[$index_html],
    debug  => false,
  }
  file { $index_html:
    ensure  => file,
    path    => "${webroot_path}/${index_html}",
    content => template("${module_name}/${index_html_template}.erb"),
    require => File[$webroot_path],
    mode    => '0755',
  }

  notify { "Generating dummy page with the jenkins command ${index_html} in the ${webroot_path}":
    before => File[$index_html],
  }
  $shell_script = 'shell.sh'
  # $shell_script_template =
  file { $shell_script:
    ensure  => file,
    path    => "/tmp/${shell_script}",
    content => template("${module_name}/${regsubst($shell_script, '\\.', '_', 'G')}.erb"),
    mode    => '0755',
  }
}
